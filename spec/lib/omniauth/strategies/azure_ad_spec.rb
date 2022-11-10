require 'rails_helper'

# rubocop:disable RSpec/FilePath

describe OmniAuth::Strategies::AzureAd do
  subject(:strategy) do
    app = Rack::Builder.new do
      use OmniAuth::Test::PhonySession

      run lambda { |_env|
        [404, { 'Content-Type' => 'text/plain' }, []]
      }
    end.to_app

    described_class.new(
      app,
      ENV.fetch('OMNIAUTH_AZURE_CLIENT_ID'),
      ENV.fetch('OMNIAUTH_AZURE_CLIENT_SECRET'),
      ENV.fetch('OMNIAUTH_AZURE_TENANT_ID')
    )
  end

  before do
    stub_auth_provider_requests
  end

  let(:kid) { SecureRandom.hex(16) }

  let(:private_key) do
    OpenSSL::PKey::RSA.generate(2048)
  end

  let(:id_token_jwt) do
    JWT.encode(
      id_token_attr,
      private_key,
      'RS256',
      kid:
    )
  end

  let(:id_token_attr) do
    valid_token_attr
  end

  let(:valid_token_attr) do
    {
      oid: SecureRandom.uuid,
      roles: ['caseworker'],
      name: 'Example, Jo',
      email: 'Jo.Example@justice.gov.uk',
      iss: 'https://login.microsoftonline.com/TestAzureTenantID/v2.0',
      sub: SecureRandom.uuid,
      aud: ENV.fetch('OMNIAUTH_AZURE_CLIENT_ID'),
      exp: 10.minutes.from_now.to_i,
      iat: Time.zone.now.to_i
    }
  end

  it 'uses PKCE' do
    expect(strategy.options.pkce).to be true
  end

  describe 'oauth2 client' do
    subject(:client) { strategy.client }

    it { is_expected.to be_a OAuth2::Client }

    it 'is configured with the correct secret' do
      expect(client.secret).to eq(
        'TestAzureClientSecret'
      )
    end

    it 'is configured with the correct url' do
      expect(client.site).to eq(
        'https://login.microsoftonline.com'
      )
    end

    it 'is configured with the correct authorize_url' do
      expect(client.options[:authorize_url]).to eq(
        'TestAzureTenantID/oauth2/v2.0/authorize'
      )
    end

    it 'is configured with the correct client_id' do
      expect(client.id).to eq(
        'TestAzureClientID'
      )
    end
  end

  describe 'info' do
    subject(:info) { strategy.info }

    # rubocop:disable RSpec/SubjectStub
    before do
      allow(strategy).to receive(:access_token).and_return(
        instance_double(
          OAuth2::AccessToken,
          token: {},
          params: { 'id_token' => id_token_jwt }
        )
      )
    end
    # rubocop:enable RSpec/SubjectStub

    it { is_expected.to be_a Hash }

    it 'includes the users id' do
      expect(info.fetch(:id)).to eq(id_token_attr.fetch(:oid))
    end

    it 'includes the user\'s email address' do
      expect(info.fetch(:email)).to eq(id_token_attr.fetch(:email))
    end

    it 'includes the user\'s first name' do
      expect(info.fetch(:first_name)).to eq('Jo')
    end

    it 'includes the user\'s last name' do
      expect(info.fetch(:last_name)).to eq('Example')
    end

    it 'includes the user\'s roles' do
      expect(info.fetch(:roles)).to eq(id_token_attr.fetch(:roles))
    end

    context 'when issuer is incorrect' do
      let(:id_token_attr) do
        valid_token_attr.merge(iss: 'https://login.microsoftonline.com/TestXTenantID/v2.0')
      end

      it 'fails' do
        expect { strategy.info }.to raise_error(/Issuer does not match/)
      end
    end

    context 'when audiance is incorrect' do
      let(:id_token_attr) do
        valid_token_attr.merge(aud: SecureRandom.hex)
      end

      it 'fails' do
        expect { strategy.info }.to raise_error(/Audience does not match/)
      end
    end

    context 'when token has exprired' do
      let(:id_token_attr) do
        valid_token_attr.merge(exp: 100.minutes.ago.to_i)
      end

      it 'fails' do
        expect { strategy.info }.to raise_error(/Expired token/)
      end
    end

    context 'when encrypted by key' do
      let(:id_token_jwt) do
        private_key = OpenSSL::PKey::RSA.generate 2048

        JWT.encode(
          id_token_attr,
          private_key,
          'RS256',
          kid:
        )
      end

      it 'fails' do
        expect { strategy.info }.to raise_error(/VerificationFailed/)
      end
    end

    context 'when kid is not found in openid_connect config' do
      let(:id_token_jwt) do
        private_key = OpenSSL::PKey::RSA.generate 2048

        JWT.encode(
          id_token_attr,
          private_key,
          'RS256',
          kid: private_key.public_key
        )
      end

      it 'fails' do
        expect { strategy.info }.to raise_error(/KidNotFound/)
      end
    end
  end

  def stub_auth_provider_requests
    stub_openid_configuration_request
    stub_openid_keys_request
  end

  def stub_openid_configuration_request
    config_url = [
      'https://login.microsoftonline.com',
      ENV.fetch('OMNIAUTH_AZURE_TENANT_ID'),
      'v2.0/.well-known/openid-configuration'
    ].join('/')

    stub_request(:get, config_url).to_return(
      status: 200,
      body: file_fixture('azure_ad_openid_config.json').read,
      headers: { 'Content-Type': 'application/json' }
    )
  end

  def stub_openid_keys_request
    keys_url = 'https://login.microsoftonline.com/TestAzureTenantID/discovery/v2.0/keys'
    jwks = [JWT::JWK.new(private_key, kid:).export].to_json

    stub_request(:get, keys_url).to_return(
      status: 200,
      body: jwks,
      headers: { 'Content-Type': 'application/json' }
    )
  end
end

# rubocop:enable RSpec/FilePath

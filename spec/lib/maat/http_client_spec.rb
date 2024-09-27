require 'rails_helper'

RSpec.describe Maat::HttpClient do
  subject(:http_client) { described_class.new(host:) }

  let(:host) { 'https://example.com/other' }
  let(:mock_access_token) { instance_double(OAuth2::AccessToken, token: 'mocked_access_token', expired?: false) }
  let(:oauth_client) { instance_double(OAuth2::Client) }
  let(:faraday_connection) { instance_double(Faraday::Connection) }

  before do
    allow(OAuth2::Client).to receive(:new).and_return(oauth_client)

    allow(oauth_client).to receive(:client_credentials).and_return(
      instance_double(
        OAuth2::Strategy::ClientCredentials, get_token: mock_access_token
      )
    )
  end

  describe '#call' do
    subject(:call) { http_client.call }

    context 'when the host is blank' do
      let(:host) { nil }

      it 'returns nil' do
        expect(call).to be_nil
      end
    end

    context 'when the host is present' do
      before do
        # Mock the Faraday connection
        allow(Faraday).to receive(:new).with(host)
                                       .and_yield(faraday_connection).and_return(faraday_connection)

        allow(faraday_connection).to receive(:request)
          .with(:authorization, 'Bearer', mock_access_token.token)

        allow(faraday_connection).to receive(:request).with(:json)
        allow(faraday_connection).to receive(:response).with(:json)
        allow(faraday_connection).to receive(:response).with(:raise_error)
        allow(faraday_connection).to receive(:adapter).with(Faraday.default_adapter)

        call
      end

      it 'returns a Faraday connection' do
        expect(call).to eq(faraday_connection)
      end

      it 'sets the authorization header with the bearer token' do
        expect(faraday_connection).to have_received(:request)
          .with(:authorization, 'Bearer', mock_access_token.token)
      end

      it 'sets the request and response types to JSON' do
        expect(faraday_connection).to have_received(:request).with(:json)
        expect(faraday_connection).to have_received(:response).with(:json)
      end

      it 'sets the response to raise errors' do
        expect(faraday_connection).to have_received(:response).with(:raise_error)
      end

      it 'uses the default Faraday adapter' do
        expect(faraday_connection).to have_received(:adapter)
          .with(Faraday.default_adapter)
      end

      describe 'when token expires' do
        before do
          allow(mock_access_token).to receive(:expired?).and_return(true)
          http_client.call
        end

        it 'is renewed' do
          expect(oauth_client.client_credentials).to have_received(:get_token).twice
        end
      end
    end
  end

  describe '#access_token' do
    subject(:access_token) { described_class.new(host:).send(:access_token) }

    context 'when the access token is not expired' do
      it 'returns the existing token' do
        access_token

        expect(oauth_client.client_credentials).to have_received(:get_token)
      end
    end

    context 'when the access token is expired' do
      before do
        allow(mock_access_token).to receive(:expired?).and_return(false)
      end

      it 'requests a new token if expired' do
        access_token

        expect(oauth_client.client_credentials).to have_received(:get_token)
      end
    end
  end

  describe '#auth_client' do
    before do
      allow(OAuth2::Client).to receive(:new).and_return(oauth_client)
      described_class.new(host:).call
    end

    it 'creates an OAuth2 client with the correct parameters' do
      expect(OAuth2::Client).to have_received(:new).with(
        'TestMaatApiClientID',
        'TestMaatApiClientSecret',
        site: 'https://oauth.example.com',
        token_url: '/oauth2/token',
        auth_scheme: :basic_auth,
        scope: 'caa-api-uat/standard'
      )
    end
  end
end

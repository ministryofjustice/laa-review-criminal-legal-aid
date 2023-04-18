require 'rails_helper'
# IMPORTANT NOTE: It is possible to change the configuration used by the
# OpenID Connect strategy in a way that still functions but undermines security.
# This spec is here to make sure such changes are not made without full consideration,
# and that the Devise initializer correctly configures the OmniAuth Strategy.

describe OmniAuth::Strategies::DevAuth do
  describe 'Devise OmniAuth strategy configuration' do
    let(:strategy) { Devise.omniauth_configs.fetch(:azure_ad).strategy }

    it 'does not use the implicit flow' do
      expect(strategy.response_type).to eq(:code)
    end

    it 'Proof Key for Code Exchange (PKCE) is enabled' do
      expect(strategy.pkce).to be(true)
    end

    it 'uses the tennant url for issuer descovery' do
      expect(strategy.discovery).to be(true)
      expect(strategy.issuer).to match(
        'https://login.microsoftonline.com/TestAzureTenantID/v2.0'
      )
    end

    it 'sets the correct client options' do
      expected_options = {
        identifier: 'TestAzureClientID',
        redirect_uri: 'https://www.example.com/users/auth/azure_ad/callback',
        secret: 'TestAzureClientSecret'
      }
      expect(strategy.client_options).to match(expected_options)
    end

    it 'only one OmniAuth strategy is configured' do
      expect(Devise.omniauth_configs.keys).to eq [:azure_ad]
    end
  end
end

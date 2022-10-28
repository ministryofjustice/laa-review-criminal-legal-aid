require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class AzureAdAuth < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, 'azure_ad_auth'

      option :tenant_id, nil

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options,
        site: 'https://login.microsoftonline.com',
        authorize_url: "/#{ENV['OMNIAUTH_AZURE_TENANT_ID']}/oauth2/v2.0/authorize",
        token_url: "/#{ENV['OMNIAUTH_AZURE_TENANT_ID']}/oauth2/v2.0/token"

  
      # You may specify that your strategy should use PKCE by setting
      # the pkce option to true: https://tools.ietf.org/html/rfc7636
      option :pkce, true

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid{ raw_info['id'] }

      # Send the scope parameter during authorize
      option :authorize_options, [:scope]

      def authorize_params
        super.tap do |params|
          params[:scope] = 'openid email profile User.Read' 
        end
      end

      
      def callback_url
        full_host + callback_path
      end

      info do
        {
          :name => raw_info['name'],
          :email => raw_info['email']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end


      def raw_info
        # Get user profile information from the /me endpoint
        @raw_info ||= access_token.get('https://graph.microsoft.com/v1.0/me').parsed
      end
    end
  end
end

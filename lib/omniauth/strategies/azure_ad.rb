require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class AzureAd < OmniAuth::Strategies::OAuth2
      class InvalidMember < StandardError; end
      class NotInTenant < StandardError; end

      args %i[client_id client_secret tenant_id]

      option :name, :azure_ad
      option :tenant_id, nil
      option :pkce, true
      option :authorize_options, [:scope]
      option :authorize_params, { scope: 'openid email profile User.Read' }

      #
      # Use custom url for OAuth2::Client to enable scoping by tenant.
      #
      def client_options
        {
          site: 'https://login.microsoftonline.com',
          authorize_url: "#{options.tenant_id}/oauth2/v2.0/authorize",
          token_url: "/#{options.tenant_id}/oauth2/v2.0/token"
        }
      end

      def client
        ::OAuth2::Client.new(options.client_id, options.client_secret, client_options)
      end

      def callback_url
        full_host + callback_path
      end

      uid { raw_info['oid'] }

      info do
        {
          auth_oid: raw_info['oid'],
          auth_subject_id: raw_info['sub'],
          email: raw_info['email'],
          first_name: raw_info['first_name'],
          last_name: raw_info['last_name']
        }
      end

      private

      #
      # Decode and validate the token.
      # Raise if token is not valid
      #
      def raw_info
        return @raw_info if @raw_info

        decoded = ::OpenIDConnect::ResponseObject::IdToken.decode(
          access_token.params['id_token'], openid_connect_config
        )

        decoded.verify!(issuer: issuer, client_id: options.client_id)

        data = decoded.raw_attributes
        validate_user_in_tenant!(data)
        data['last_name'], data['first_name'] = data.fetch('name').split(', ')

        @raw_info = data
      end

      def validate_user_in_tenant!(data)
        raise InvalidMember, 'Invalid ID token: User is not a tenant member.' unless data['acct']&.zero?
        raise NotInTenant, 'Invalid ID token: Tenant does not match tid.' unless data['tid'] == options.tenant_id
      end

      def issuer
        "https://login.microsoftonline.com/#{options.tenant_id}/v2.0"
      end

      def openid_connect_config
        ::OpenIDConnect::Discovery::Provider::Config.discover!(issuer)
      end
    end
  end
end

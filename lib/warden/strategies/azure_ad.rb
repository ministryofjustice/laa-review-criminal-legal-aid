module Warden
  module Strategies
    class AzureAd < Warden::Strategies::Base
      #
      # halt and redirect to provider authentication unless valid id_token
      #
      # halt and redirect to forbidden unless user with subject id exists
      #
      def authenticate!
        throw(:warden, action: 'authenticate') unless auth_info

        if (user = User.authenticate!(auth_info))
          success! user
        else
          throw(:warden, action: 'forbidden')
        end
      end

      private

      def auth_info
        env.dig('omniauth.auth', 'info')
      end
    end
  end

  class AzureAdFailureController < ActionController::Metal
    include ActionController::Redirecting

    def self.call(env)
      @respond = action(env['warden.options'][:action] || :forbidden)
      @respond.call(env)
    end

    def forbidden
      redirect_to '/forbidden'
    end

    def authenticate
      redirect_to '/auth/azure_ad'
    end
  end
end

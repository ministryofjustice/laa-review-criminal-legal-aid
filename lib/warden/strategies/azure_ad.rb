module Warden
  module Strategies
    class AzureAd < Warden::Strategies::Base
      #
      # halt and redirect to provider authentication unless valid id_token
      #
      # halt and redirect to forbidden unless user with subject id exists
      #
      def authenticate!
        throw(:warden, action: 'authenticate') unless auth_hash

        user = UserAuthenticate.new(auth_hash).authenticate!

        if user
          success! user
        else
          throw(:warden, action: 'forbidden')
        end
      end

      def auth_hash
        env['omniauth.auth']
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

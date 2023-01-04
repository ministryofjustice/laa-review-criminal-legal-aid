module Warden
  module Strategies
    class AzureAd < Warden::Strategies::Base
      def authenticate!
        omniauth_user = env['omniauth.auth']

        if omniauth_user
          info = env['omniauth.auth']['info']

          success! find_and_update_user(info)
        else
          fail!
        end
      end

      def find_and_update_user(info)
        User.upsert(
          {
            auth_oid: info.fetch('auth_oid'),
            first_name: info['first_name'],
            last_name: info['last_name']
          },
          unique_by: :auth_oid
        ).first.fetch('id')
      end
    end
  end

  class AzureAdFailureController < ActionController::Metal
    include ActionController::Redirecting

    def self.call(env)
      @respond ||= action(:respond)
      @respond.call(env)
    end

    def respond
      redirect_to '/auth/azure_ad'
    end
  end
end

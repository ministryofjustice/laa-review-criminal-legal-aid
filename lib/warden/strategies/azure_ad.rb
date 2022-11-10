module Warden
  module Strategies
    class AzureAd < Warden::Strategies::Base
      def authenticate!
        user = env['omniauth.auth']

        if user
          success! user.info
        else
          fail!
        end
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

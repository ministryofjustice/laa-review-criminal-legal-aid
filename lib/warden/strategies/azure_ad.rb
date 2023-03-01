module Warden
  module Strategies
    class AzureAd < Warden::Strategies::Base
      def authenticate!
        info = env.dig('omniauth.auth', 'info')

        if info && (user = User.authenticate!(info))
          success! user
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

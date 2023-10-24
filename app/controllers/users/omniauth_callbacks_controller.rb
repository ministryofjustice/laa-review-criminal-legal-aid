module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def azure_ad
      @user = UserAuthenticate.new(request.env['omniauth.auth']).authenticate

      raise ApplicationController::ForbiddenError, 'User not authorised' unless @user

      sign_in_and_redirect @user, event: :authentication
    end

    def failure
      raise ApplicationController::ForbiddenError, 'Devise failure'
    end

    # Override the #passthru action. It is used when a GET request is made
    # to the user auth url. Ideally the GET route would not be added by Devise.
    # The fix for this is in Devise but awaiting release:
    # https://github.com/heartcombo/devise/pull/5508
    def passthru
      raise ActionController::RoutingError, 'Get requests should not be supported.'
    end
  end
end

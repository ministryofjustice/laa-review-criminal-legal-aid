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
  end
end

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def azure_ad
      @user = UserAuthenticate.new(request.env['omniauth.auth']).authenticate

      if @user
        sign_in_and_redirect @user, event: :authentication
      else
        throw(:warden, recall: 'Errors#forbidden', message: :forbidden)
      end
    end

    def failure
      throw(:warden, recall: 'Errors#forbidden', message: :forbidden)
    end
  end
end

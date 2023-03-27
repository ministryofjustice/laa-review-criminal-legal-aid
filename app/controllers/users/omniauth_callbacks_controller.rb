module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def azure_ad
      @user = UserAuthenticate.new(request.env['omniauth.auth']).authenticate!

      if @user
        sign_in_and_redirect @user, event: :authentication
      else
        redirect_to forbidden_path
      end
    end

    def failure
      redirect_to forbidden_path
    end
  end
end

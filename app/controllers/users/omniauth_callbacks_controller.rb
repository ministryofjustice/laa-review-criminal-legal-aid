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

    # Override the #passthru action. It is used when a GET request is made
    # to the user auth url. Ideally the GET route would not be added by Devise.
    # The fix for this is in Devise but awaiting release:
    # https://github.com/heartcombo/devise/pull/5508
    def passthru
      redirect_to unauthenticated_root_path
    end
  end
end

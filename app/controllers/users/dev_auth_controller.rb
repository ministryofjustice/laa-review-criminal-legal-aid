module Users
  class DevAuthController < Devise::SessionsController
    layout 'external'

    def new
      redirect_to application_not_found_path and return unless FeatureFlags.dev_auth.enabled?

      @emails = User.all.order(last_auth_at: :desc).pluck(:email) << OmniAuth::Strategies::DevAuth::NO_AUTH_EMAIL
    end
  end
end

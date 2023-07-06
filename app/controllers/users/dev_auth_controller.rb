module Users
  class DevAuthController < Devise::SessionsController
    layout 'external'

    def new
      raise ActionController::RoutingError unless FeatureFlags.dev_auth.enabled?

      @emails = User.all.order(last_auth_at: :desc).pluck(:email) << OmniAuth::Strategies::DevAuth::NO_AUTH_EMAIL
    end
  end
end

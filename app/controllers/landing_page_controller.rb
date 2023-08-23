class LandingPageController < ApplicationController
  before_action :authenticate_user!

  def index
    url = landing_page_for(current_user)
    raise ForbiddenError, "Unknown landing page for user role #{current_user.role}" if url.blank?

    redirect_to url
  end
end

class ServiceController < ApplicationController
  before_action :authenticate_user!
  before_action :require_service_user!

  private

  #
  # Users that can manage others are only allowed to access the Service on staging.
  # This is configured by the allow_user_managers_service_access feature flag.
  #
  def require_service_user!
    return if current_user.service_user?
    return if FeatureFlags.allow_user_managers_service_access.enabled?

    redirect_to admin_manage_users_root_path
  end

  def set_search(filter: ApplicationSearchFilter.new, sorting: {})
    sorting = Sorting.new(
      permitted_params[:sorting] || sorting.to_h
    )

    pagination = Pagination.new(
      current_page: permitted_params[:page],
      limit_value: permitted_params[:per_page]
    )

    @search = ApplicationSearch.new(
      filter:, sorting:, pagination:
    )
  end
end

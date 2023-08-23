class ServiceController < ApplicationController
  before_action :authenticate_user!
  before_action :require_service_user!
  before_action :set_security_headers

  helper_method :assignments_count

  rescue_from DatastoreApi::Errors::ApiError do |e|
    Rails.error.report(e, handled: true, severity: :error)

    render status: :internal_server_error, template: 'errors/datastore_error'
  end

  rescue_from DatastoreApi::Errors::NotFoundError do
    render status: :not_found, template: 'errors/application_not_found'
  end

  private

  #
  # Users that can manage others are only allowed to access the Service on staging.
  # This is configured by the allow_user_managers_service_access feature flag.
  #
  def require_service_user!
    return if current_user.service_user?
    return if allow_user_managers_service_access?

    raise ForbiddenError, 'Must be a service user'
  end

  def assignments_count
    @assignments_count ||= CurrentAssignment.where(
      user_id: current_user_id
    ).count
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

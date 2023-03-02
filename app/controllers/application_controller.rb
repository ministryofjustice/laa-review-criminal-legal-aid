class ApplicationController < ActionController::Base
  include ErrorHandling

  before_action :authenticate_user!
  helper_method :current_user_id
  helper_method :current_user_name
  helper_method :assignments_count

  private

  def assignments_count
    @assignments_count ||= CurrentAssignment.where(
      user_id: current_user_id
    ).count
  end

  def current_user_id
    warden.user.first.fetch('id')
  end

  def current_user_name
    @current_user_name || warden.user.first.values_at('first_name', 'last_name').join(' ')
  end

  def authenticate_user!
    warden.authenticate!(:azure_ad)
  end

  def warden
    request.env['warden']
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
      filter:,
      sorting:,
      pagination:
    )
  end
end

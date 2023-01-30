class ApplicationController < ActionController::Base
  include ErrorHandling

  before_action :authenticate_user!
  helper_method :current_user_id
  helper_method :assignments_count

  private

  def assignments_count
    @assignments_count ||= CurrentAssignment.where(
      user_id: current_user_id
    ).count
  end

  def current_user_id
    warden.user.first
  end

  def authenticate_user!
    warden.authenticate!(:azure_ad)
  end

  def warden
    request.env['warden']
  end

  def set_search(filter: ApplicationSearchFilter.new, default_sort_by: 'submitted_at')
    sorting = Sorting.new(
      permitted_params[:sorting] || { sort_by: default_sort_by }
    )

    pagination = Pagination.new(current_page: permitted_params[:page] || 1)

    @search = ApplicationSearch.new(
      filter:,
      sorting:,
      pagination:
    )
  end
end

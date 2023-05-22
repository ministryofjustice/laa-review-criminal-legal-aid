class ApplicationController < ActionController::Base
  include ErrorHandling

  before_action :authenticate_user!
  helper_method :current_user_id
  helper_method :assignments_count

  private

  def current_user_id
    current_user&.id
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

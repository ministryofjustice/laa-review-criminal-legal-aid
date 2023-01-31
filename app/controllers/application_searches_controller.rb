class ApplicationSearchesController < ApplicationController
  before_action :set_sort_filter

  def new; end

  def create
    @search = ApplicationSearch.new(filter: @filter, sorting: @sorting)

    render :show
  end

  private

  def set_sort_filter
    @filter = ApplicationSearchFilter.new(permitted_params[:filter])
    @sorting = Sorting.new(permitted_params[:sorting])
  end

  def permitted_params
    params.permit(
      filter: ApplicationSearchFilter.attribute_names,
      sorting: Sorting.attribute_names
    )
  end
end

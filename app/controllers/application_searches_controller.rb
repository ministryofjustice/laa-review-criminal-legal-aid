class ApplicationSearchesController < ApplicationController
  def new
    @filter = ApplicationSearchFilter.new
    @sorting = Sorting.new
  end

  def create
    @filter = ApplicationSearchFilter.new(search_params)
    @sorting = Sorting.new(sort_params)

    @search = ApplicationSearch.new(filter: @filter, sorting: @sorting)

    render :show
  end

  private

  def search_params
    params[:search][:application_search_filter].permit(ApplicationSearchFilter.attribute_names)
  end

  def sort_params
    params[:search][:sorting]&.permit(Sorting.attribute_names)
  end
end

class ApplicationSearchesController < ApplicationController
  def create
    @filter = ApplicationSearchFilter.new(search_params)
    @search = ApplicationSearch.new(filter: @filter)
    @applications = @search.applications

    render :show
  end

  private

  def search_params
    params[:filter].permit(ApplicationSearchFilter.attribute_names)
  end
end

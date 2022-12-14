class ApplicationSearchesController < ApplicationController
  def new
    @filter = ApplicationSearchFilter.new
  end

  def create
    @filter = ApplicationSearchFilter.new(search_params)
    @search = ApplicationSearch.new(filter: @filter)

    render :show
  end

  def download
    filter = ApplicationSearchFilter.new(search_params)
    csv = ApplicationSearchCsv.new(filter:)

    send_data csv.csv, filename: csv.file_name
  end

  private

  def search_params
    params[:filter].permit(ApplicationSearchFilter.attribute_names)
  end
end

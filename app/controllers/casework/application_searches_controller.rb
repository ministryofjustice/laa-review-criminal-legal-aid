module Casework
  class ApplicationSearchesController < Casework::BaseController
    def new
      @filter = ApplicationSearchFilter.new
    end

    def search
      @filter = ApplicationSearchFilter.new(permitted_params[:filter])
      set_search(filter: @filter)

      render :show
    end

    private

    def permitted_params
      params.permit(
        :page,
        :per_page,
        filter: ApplicationSearchFilter.attribute_names,
        sorting: Sorting.attribute_names
      )
    end
  end
end

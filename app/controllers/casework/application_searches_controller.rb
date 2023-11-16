module Casework
  class ApplicationSearchesController < Casework::BaseController
    include ApplicationSearchable

    def new
      set_filter
    end

    def search
      set_search(default_sorting: { sort_by: 'submitted_at', sort_direction: 'ascending' })
    end
  end
end

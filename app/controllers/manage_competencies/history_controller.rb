module ManageCompetencies
  class HistoryController < ManageCompetencies::BaseController
    def show
      @caseworker = user_scope.find(params.expect(:id))
    end
  end
end

module ManageCompetencies
  class HistoryController < ManageCompetencies::BaseController
    def show
      @caseworker = User.caseworker.find(params[:id])
    end
  end
end

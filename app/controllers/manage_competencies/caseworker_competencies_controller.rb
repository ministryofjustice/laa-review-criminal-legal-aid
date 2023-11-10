module ManageCompetencies
  class CaseworkerCompetenciesController < BaseController
    def index
      @caseworkers = User.caseworker.order(first_name: :asc, last_name: :asc).page params[:page]
    end

    def edit
      @caseworker = User.caseworker.find(params[:id])
    end

    def update
      @caseworker = User.caseworker.find(params[:id])
      redirect_to manage_competencies_root_path
    end
  end
end

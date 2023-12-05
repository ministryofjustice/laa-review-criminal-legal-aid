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
      competencies = permitted_params[:competencies].compact_blank
      Allocating::SetCompetencies.call(user: @caseworker, by_whom: current_user, competencies: competencies)
      set_flash(:permissions_updated, user_name: @caseworker.name)
      redirect_to manage_competencies_root_path
    end

    private

    def permitted_params
      params.require(:user).permit(competencies: [])
    end
  end
end

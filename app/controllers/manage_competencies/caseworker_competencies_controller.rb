module ManageCompetencies
  class CaseworkerCompetenciesController < BaseController
    def index
      @caseworkers = user_scope.order(first_name: :asc, last_name: :asc).page params[:page]
    end

    def edit
      @caseworker = user_scope.find(params[:id])
    end

    def update
      user = user_scope.find(params[:id])
      competencies = permitted_params[:competencies].compact_blank

      Allocating::SetCompetencies.call(
        user: user,
        by_whom: current_user,
        competencies: competencies
      )

      set_flash(:competencies_updated, user_name: user.name)
      redirect_to manage_competencies_root_path
    end

    private

    def permitted_params
      params.require(:user).permit(competencies: [])
    end

    def user_scope
      User.active.where(
        role: [Types::CASEWORKER_ROLE, Types::SUPERVISOR_ROLE],
        can_manage_others: false
      )
    end
  end
end

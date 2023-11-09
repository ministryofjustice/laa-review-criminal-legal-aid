module ManageCompetencies
  class CaseworkerSkillsController < BaseController
    def index
      @users = User.caseworker.order(first_name: :asc, last_name: :asc).page params[:page]
    end
  end
end

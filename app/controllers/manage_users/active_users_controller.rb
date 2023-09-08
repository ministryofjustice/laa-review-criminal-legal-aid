module ManageUsers
  class ActiveUsersController < BaseController
    def index
      @users = User.active.order(first_name: :asc, last_name: :asc).page params[:page]
    end
  end
end

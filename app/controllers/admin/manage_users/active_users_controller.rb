module Admin
  module ManageUsers
    class ActiveUsersController < ManageUsersController
      def index
        @users = User.active.order(first_name: :asc, last_name: :asc).page params[:page]
      end
    end
  end
end

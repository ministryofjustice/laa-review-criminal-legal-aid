module Admin
  module ManageUsers
    class HistoryController < ManageUsersController
      def show
        @user = User.find(params[:id])
      end
    end
  end
end

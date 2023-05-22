module Admin
  module ManageUsers
    class DeactivatedUsersController < ManageUsersController
      def new
        @user = user_scope.find(params[:active_user_id])
      end

      def create
        user = user_scope.find(params[:active_user_id])
        user.deactivate!

        set_flash :user_deactivated, user_name: user.name
        redirect_to admin_manage_users_root_path
      end

      private

      def user_scope
        User.active
      end
    end
  end
end

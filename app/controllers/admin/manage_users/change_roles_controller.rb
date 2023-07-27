module Admin
  module ManageUsers
    class ChangeRolesController < ManageUsersController
      before_action :set_user

      def edit; end

      def update
        old_role = @user.role.humanize.capitalize
        @user.change_role!

        set_flash :user_change_role, user_name: @user.name, old_role: old_role, new_role: @user.role.capitalize.humanize
        redirect_to admin_manage_users_root_path
      end

      def set_user
        @user = User.active.find(params[:id])
      end
    end
  end
end

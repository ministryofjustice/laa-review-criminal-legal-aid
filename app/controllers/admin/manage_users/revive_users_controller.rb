module Admin
  module ManageUsers
    class ReviveUsersController < ManageUsersController
      before_action :set_active_user, only: [:edit]

      def edit
        set_flash :user_revived, user_name: @user.name
        redirect_to admin_manage_users_root_path
      end

      private

      def set_active_user
        @user = User.active.find(params[:id])
      end
    end
  end
end

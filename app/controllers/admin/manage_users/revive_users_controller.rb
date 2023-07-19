module Admin
  module ManageUsers
    class ReviveUsersController < ManageUsersController
      before_action :set_active_user, only: [:edit]

      def edit
        if @user.dormant?
          Authorising::AwaitRevival.new(
            user: @user,
            user_manager_id: current_user_id
          ).call

          set_flash :user_revive, user_name: @user.name
        else
          set_flash :revive_denied, success: false, user_name: @user.name
        end
      rescue User::CannotAwaitRevival
        set_flash :revive_denied, success: false, user_name: @user.name
      ensure
        redirect_to admin_manage_users_root_path
      end

      private

      def set_active_user
        @user = User.active.find(params[:id])
      end
    end
  end
end

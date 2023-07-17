module Admin
  module ManageUsers
    class ReviveUsersController < ManageUsersController
      before_action :set_active_user, only: [:edit]

      def edit
        if @user.dormant?
          # set revive_until equal to today = today +48 hours
          # send email to dormant user
          set_flash :user_revive, user_name: @user.name
          redirect_to admin_manage_users_root_path
        else
          # redirect user to manage user screen with notification error
          set_flash :revive_denied, success: false, user_name: @user.name
          redirect_to admin_manage_users_root_path
        end
      end

      private

      def set_active_user
        @user = User.active.find(params[:id])
      end
    end
  end
end

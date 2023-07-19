module Admin
  module ManageUsers
    class ReviveUsersController < ManageUsersController
      before_action :set_active_user, only: [:edit]

      # TODO: Generate RevivalAwaited Event
      def edit
        if @user.dormant?
          @user.revive_until = Rails.configuration.x.auth.dormant_account_revive_ttl.from_now
          @user.save!

          NotifyMailer.revive_account_email(@user.email).deliver_now
          set_flash :user_revive, user_name: @user.name
        else
          set_flash :revive_denied, success: false, user_name: @user.name
        end
        redirect_to admin_manage_users_root_path
      end

      private

      def set_active_user
        @user = User.active.find(params[:id])
      end
    end
  end
end

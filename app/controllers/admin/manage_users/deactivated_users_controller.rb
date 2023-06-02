module Admin
  module ManageUsers
    class DeactivatedUsersController < ManageUsersController
      before_action :set_user
      before_action :allow_deactivation?

      def create
        set_flash :user_deactivated, user_name: @user.name if @user.deactivate!
        redirect_to admin_manage_users_root_path
      end

      private

      def set_user
        @user = User.active.find(params[:active_user_id])
      end

      def allow_deactivation?
        return if @user.deactivatable?

        flash[:alert] = I18n.t('flash.alert.user_deactivated')
        admin_manage_users_root_path      
      end
    end
  end
end

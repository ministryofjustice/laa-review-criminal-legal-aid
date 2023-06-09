module Admin
  module ManageUsers
    class DeactivatedUsersController < ManageUsersController
      before_action :set_user, only: [:new, :create]
      before_action :allow_deactivation?, only: [:new, :create]

      def index
        @users = User.deactivated.page(params[:page])
      end

      def new; end

      def create
        set_flash :user_deactivated, user_name: @user.name if @user.deactivate!
        redirect_to admin_manage_users_root_path
      end

      def confirm_reactivate
        @user = User.deactivated.find(params[:id])
      end

      def reactivate
        user = User.deactivated.find(params[:id])
        user.reactivate!

        set_flash(:user_reactivated, user_name: user.name)
        redirect_to admin_manage_users_root_path
      end

      private

      def set_user
        @user = User.active.find(params[:id])
      end

      def allow_deactivation?
        return if @user.deactivatable?

        flash[:alert] = I18n.t('flash.alert.user_deactivation_denied')
        redirect_to admin_manage_users_root_path
      end
    end
  end
end

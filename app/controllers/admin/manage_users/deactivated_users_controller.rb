module Admin
  module ManageUsers
    class DeactivatedUsersController < ManageUsersController
      before_action :set_active_user, only: [:new, :create]
      before_action :allow_deactivation?, only: [:new, :create]

      before_action :set_deactivated_user, only: [:confirm_reactivate, :reactivate]
      before_action :allow_reactivation?, only: [:confirm_reactivate, :reactivate]

      def index
        @users = User.deactivated.page(params[:page])
      end

      def new; end

      def create
        Authorising::Deactivate.new(
          user: @user, user_manager_id: current_user_id
        ).call

        set_flash :user_deactivated, user_name: @user.name
      ensure
        redirect_to admin_manage_users_root_path
      end

      def confirm_reactivate; end

      def reactivate
        Authorising::Reactivate.new(
          user: @user, user_manager_id: current_user_id
        ).call

        set_flash(:user_reactivated, user_name: @user.name)
      ensure
        redirect_to admin_manage_users_root_path
      end

      private

      def set_active_user
        @user = User.active.find(params[:id])
      end

      def set_deactivated_user
        @user = User.deactivated.find(params[:id])
      end

      def allow_deactivation?
        return if @user.deactivatable?

        flash[:alert] = I18n.t('flash.alert.user_deactivation_denied')
        redirect_to admin_manage_users_root_path
      end

      def allow_reactivation?
        return if @user != current_user

        set_flash(:reactivation_denied, success: false)
        redirect_to admin_manage_users_deactivated_users_path
      end
    end
  end
end

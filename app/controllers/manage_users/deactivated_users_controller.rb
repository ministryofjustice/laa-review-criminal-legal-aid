module ManageUsers
  class DeactivatedUsersController < ManageUsers::BaseController
    before_action :set_active_user, only: [:new, :create]
    before_action :set_deactivated_user, only: [:confirm_reactivate, :reactivate]

    def index
      @users = User.deactivated.page(params[:page])
    end

    def new; end

    def create
      Authorising::Deactivate.new(
        user: @user, user_manager_id: current_user_id
      ).call

      set_flash :user_deactivated, user_name: @user.name
    rescue User::CannotDeactivate
      set_flash(:deactivation_denied, success: false)
    ensure
      redirect_to manage_users_root_path
    end

    def confirm_reactivate; end

    def reactivate
      Authorising::Reactivate.new(
        user: @user, user_manager_id: current_user_id
      ).call

      set_flash(:user_reactivated, user_name: @user.name)
      redirect_to manage_users_root_path
    rescue User::CannotReactivate
      set_flash(:reactivation_denied, success: false)
      redirect_to manage_users_deactivated_users_path
    end

    private

    def set_active_user
      @user = User.active.find(params[:id])
    end

    def set_deactivated_user
      @user = User.deactivated.find(params[:id])
    end
  end
end

module ManageUsers
  class ReviveUsersController < ManageUsers::BaseController
    before_action :set_active_user, only: [:edit]

    def edit
      begin_revival
    rescue User::CannotAwaitRevival
      denied
    ensure
      redirect_to manage_users_root_path
    end

    private

    def begin_revival
      Authorising::AwaitRevival.new(
        user: @user,
        user_manager_id: current_user_id
      ).call

      set_flash :user_revive, user_name: @user.name
    end

    def denied
      set_flash :revive_denied, success: false, user_name: @user.name
    end

    def set_active_user
      @user = User.active.find(params[:id])
    end
  end
end

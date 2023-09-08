module ManageUsers
  class ChangeRolesController < ManageUsers::BaseController
    before_action :set_user
    before_action :allow_change_role?
    before_action :allow_new_role?, only: [:update]

    def edit; end

    def update
      change_role
    rescue User::CannotChangeRole
      denied
    ensure
      redirect_to manage_users_root_path
    end

    private

    def set_user
      @user = User.active.find(params[:id])
    end

    def change_role # rubocop:disable Metrics/MethodLength
      command = Authorising::ChangeRole.new(
        user: @user,
        user_manager_id: current_user_id,
        from: @user.role,
        to: params[:role]
      )
      command.call

      set_flash(
        :user_change_role,
        user_name: @user.name,
        from: command.from.humanize,
        to: command.to.humanize
      )
    end

    def allow_change_role?
      return true if @user.can_change_role?

      denied
      redirect_to manage_users_root_path
    end

    def allow_new_role?
      return true if params[:role].present?

      set_flash(:change_role_failed, user_name: @user.name, success: false)
      redirect_to manage_users_root_path
    end

    def denied
      set_flash :change_role_denied, success: false, user_name: @user.name
    end
  end
end

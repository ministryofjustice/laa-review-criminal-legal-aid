module Admin
  module ManageUsers
    class ActiveUsersController < ManageUsersController
      before_action :set_user, only: [:edit, :update]

      def index
        @users = user_scope.order(
          first_name: :asc, last_name: :asc
        ).page params[:page]
      end

      def edit; end

      def update
        can_manage_others = params[:can_manage_others] ? true : false

        if @user.allow_admin_right_change?(can_manage_others) && @user.update(can_manage_others:)
          set_flash(:user_updated, user_name: @user.name)
          redirect_to admin_manage_users_root_path
        else
          set_flash(:deactivation_denied, success: false)
          redirect_to edit_admin_manage_users_active_user_path(@user)
        end
      end

      private

      def user_scope
        User.active
      end

      def set_user
        @user = user_scope.find(params[:id])
      end
    end
  end
end

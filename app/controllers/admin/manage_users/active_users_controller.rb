module Admin
  module ManageUsers
    class ActiveUsersController < ManageUsersController
      def index
        @users = user_scope.order(
          first_name: :asc, last_name: :asc
        ).page params[:page]
      end

      def edit
        @user = user_scope.find(params[:id])
      end

      def update
        can_manage_others = params[:can_manage_others] ? true : false

        @user = user_scope.find(params[:id])

        if @user.update(can_manage_others:)
          set_flash(:user_updated, user_name: @user.name)
          redirect_to admin_manage_users_root_path
        else
          render :edit
        end
      end

      private

      def user_scope
        User.active
      end
    end
  end
end

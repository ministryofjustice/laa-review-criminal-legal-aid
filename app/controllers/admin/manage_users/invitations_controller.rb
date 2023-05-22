module Admin
  module ManageUsers
    class InvitationsController < ManageUsersController
      def index
        @users = user_scope.order(first_name: :asc, last_name: :asc).page(
          params[:page]
        )
      end

      def new
        @new_user_form = Admin::NewUserForm.new
      end

      def create
        @new_user_form = Admin::NewUserForm.new(user_params)

        if @new_user_form.save
          set_flash(:user_invited, email: @new_user_form.email)
          redirect_to admin_manage_users_invitations_path
        else
          render :new
        end
      end

      def update
        user = user_scope.find(params[:id])
        user.renew_invitation!

        set_flash(:invitation_renewed, email: user.email)
        redirect_to admin_manage_users_invitations_path
      end

      def destroy
        user = user_scope.find(params[:id])
        user.destroy

        set_flash(:invitation_deleted, success: true, email: user.email)
        redirect_to admin_manage_users_invitations_path
      end

      private

      def user_params
        params.require(:admin_new_user_form).permit(:email, :can_manage_others)
      end

      def user_scope
        User.pending_activation
      end
    end
  end
end

module Admin
  module ManageUsers
    class InvitationsController < ManageUsersController
      before_action :set_user, except: %i[index new create]

      def index
        @users = user_scope.order(first_name: :asc, last_name: :asc).page(params[:page])
      end

      def new
        @user = User.new
      end

      def create
        user = User.new(user_params)

        if user.valid?
          Authorising::Invite.call(
            user: user,
            user_manager_id: current_user.id
          )

          set_flash(:user_invited, email: user.email)
          redirect_to admin_manage_users_invitations_path
        else
          @user = user
          render :new
        end
      end

      def update
        Authorising::RenewInvite.call(
          user: @user,
          user_manager_id: current_user.id
        )

        set_flash(:invitation_renewed, email: @user.email)
        redirect_to admin_manage_users_invitations_path
      end

      def confirm_destroy; end
      def confirm_renew; end

      def destroy
        Authorising::RevokeInvite.call(
          user: @user,
          user_manager_id: current_user.id
        )

        set_flash :invitation_deleted, success: true, email: @user.email
        redirect_to admin_manage_users_invitations_path
      end

      private

      def user_params
        params.require(:user).permit(:email, :can_manage_others)
      end

      def set_user
        @user = user_scope.find(params[:id])
      end

      def user_scope
        User.pending_activation
      end
    end
  end
end

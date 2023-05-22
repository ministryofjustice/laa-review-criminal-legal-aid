module Admin
  class ManageUsersController < ApplicationController
    layout 'manage_users'

<<<<<<< HEAD
    def text_namespace
      'manage_users'
    end

    before_action :require_user_manager!

    def index
      @users = User.all.order(first_name: :asc, last_name: :asc)
                   .page(params[:page])
    end

    def new
      @new_user_form = Admin::NewUserForm.new
    end

    def edit
      @user = User.find(params[:id])
    end

    def create
      @new_user_form = Admin::NewUserForm.new(user_params)

      if @new_user_form.save
        set_flash(:new_user_created)

        redirect_to admin_manage_users_path
      else
        render :new
      end
    end

    def update
      can_manage_others = params[:can_manage_others] ? true : false

      @user = User.find(params[:id])

      if @user.update(can_manage_others:)
        set_flash(:user_updated)

        redirect_to admin_manage_users_path
      else
        render :edit
      end
    end

    private

    def user_params
      params.require(:admin_new_user_form).permit(:email, :can_manage_others)
    end

=======
    # Scope for I18n locale, used by _text helpers.
    def text_namespace
      :manage_users
    end

    before_action :require_user_manager!

    private

>>>>>>> 094a05b (CRIMRE-320-manage-invitations)
    def require_user_manager!
      return if current_user.can_manage_others?

      set_flash(:cannot_access, success: false)

      redirect_to authenticated_root_path
    end
  end
end

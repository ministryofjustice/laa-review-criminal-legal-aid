require_relative '../../forms/admin/new_user_form'
module Admin
  class ManageUsersController < ApplicationController
    def index
      if current_user.can_manage_others
        @users = User.all
      else
        flash[:important] = :cannot_access

        redirect_to assigned_applications_path
      end
    end

    def new
      @new_user_form = Admin::NewUserForm.new
    end

    def create
      @new_user_form = Admin::NewUserForm.new(user_params)

      if @new_user_form.save
        flash[:success] = :new_user_created
        redirect_to admin_manage_users_path
      else
        render :new
      end
    end

    def user_params
      params.require(:admin_new_user_form).permit(:email, :can_manage_others)
    end
  end
end

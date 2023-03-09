module Admin
  class ManageUsersController < ApplicationController
    def index
      if current_user.can_manage_others
        @users = User.all.order(first_name: :asc, last_name: :asc)
      else
        flash[:important] = :cannot_access

        redirect_to assigned_applications_path
      end
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
        flash[:success] = :new_user_created
        redirect_to admin_manage_users_path
      else
        render :new
      end
    end

    def update
      can_manage_others = params[:can_manage_others] ? true : false

      @user = User.find(params[:id])

      if @user.update(can_manage_others:)
        flash[:success] = :user_updated
        redirect_to admin_manage_users_path
      else
        render :edit
      end
    end

    def user_params
      params.require(:admin_new_user_form).permit(:email, :can_manage_others)
    end
  end
end

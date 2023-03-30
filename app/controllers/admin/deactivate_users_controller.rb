module Admin
  class DeactivateUsersController < ApplicationController
    def new
      @user = User.find(params[:manage_user_id])
    end

    def create
      @user = User.find(params[:manage_user_id])
      @user.deactivate!

      flash[:success] = I18n.t('flash.success.user_deactivated')
      redirect_to admin_manage_users_path
    end
  end
end

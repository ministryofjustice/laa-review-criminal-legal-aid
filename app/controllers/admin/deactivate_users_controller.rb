module Admin
  class DeactivateUsersController < ApplicationController
    before_action :set_user
    before_action :allow_deactivation?

    def create
      flash[:success] = I18n.t('flash.success.user_deactivated') if @user.deactivate!

      redirect_to admin_manage_users_path
    end

    private

    def set_user
      @user = User.find(params[:manage_user_id])
    end

    def allow_deactivation?
      return if @user.deactivatable?

      flash[:alert] = I18n.t('flash.alert.user_deactivated')
      redirect_to admin_manage_users_path
    end
  end
end

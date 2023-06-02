module Admin
  class DeactivateUsersController < ApplicationController
    before_action :set_user
    before_action :deactivatable?

    def create
      if @user.deactivate!
        flash[:success] = I18n.t('flash.success.user_deactivated')
      else
        flash[:alert] = I18n.t('flash.alert.user_deactivated')
      end

      redirect_to admin_manage_users_path
    end

    private

    def set_user
      @user = User.find(params[:manage_user_id])
    end

    def deactivatable?
      return if @user.allow_deactivate?

      flash[:alert] = I18n.t('flash.alert.user_deactivated')
      redirect_to admin_manage_users_path
    end
  end
end

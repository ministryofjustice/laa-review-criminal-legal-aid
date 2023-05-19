module Admin
  class DeactivateUsersController < ApplicationController
    def new
      @user = User.find(params[:manage_user_id])

    #   if user can be deactivated
    #     show the deactivate user page

    #   elsif user can not be deactivated
    #     show the manage users screen with error message
    #   end
    # end
    
      if @user.allow_deactivate?

      else
        redirect_to admin_manage_users_path
        flash[:alert] = I18n.t('flash.alert.user_deactivated')
      end
    end

    def create
      @user = User.find(params[:manage_user_id])
      user_deactivated = @user.deactivate!

      if user_deactivated == true
        flash[:success] = I18n.t('flash.success.user_deactivated')
        redirect_to admin_manage_users_path

      elsif user_deactivated == nil
        flash[:alert] = I18n.t('flash.alert.user_deactivated')
        redirect_to admin_manage_users_path
      end
    end
  end
end

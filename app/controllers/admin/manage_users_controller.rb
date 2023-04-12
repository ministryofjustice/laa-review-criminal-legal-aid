module Admin
  class ManageUsersController < ApplicationController
    layout 'manage_users'

    before_action :require_user_manager!
    before_action :protect_return_url, only: [:edit, :update]

    def index
      page = (index_params[:page].presence || 1)
      per_page = Rails.configuration.x.pagination.per_page
      @users = User.all.order(first_name: :asc, last_name: :asc).page(page).per(per_page)
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
        flash_and_redirect(:success, :new_user_created)
      else
        render :new
      end
    end

    def update
      can_manage_others = params[:can_manage_others] ? true : false

      @user = User.find(params[:id])

      if @user.update(can_manage_others:)
        flash_and_redirect(:success, :user_updated)
      else
        render :edit
      end
    end

    private

    def flash_and_redirect(key, message)
      flash[key] = I18n.t(message, scope: [:flash, key])

      if @return_url.present?
        redirect_to @return_url
      else
        redirect_to admin_manage_users_path
      end
    end

    def user_params
      params.require(:admin_new_user_form).permit(:email, :can_manage_others)
    end

    def require_user_manager!
      return if current_user.can_manage_others?

      flash[:important] = I18n.t('flash.important.cannot_access')
      redirect_to authenticated_root_path
    end

    def index_params
      params.permit(:page)
    end

    def protect_return_url
      return if params[:return_url].blank?

      @return_url = URI.parse(params[:return_url]).to_s
      @return_url = nil unless @return_url.start_with?(root_url)
    rescue URI::InvalidURIError
      @return_url = nil
    end
  end
end

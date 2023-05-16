module Admin
  class ManageUsersController < ApplicationController
    layout 'manage_users'

    # Scope for I18n locale, used by _text helpers.
    def text_namespace
      :manage_users
    end

    before_action :require_user_manager!

    private

    def require_user_manager!
      return if current_user.can_manage_others?

      flash[:important] = I18n.t('flash.important.cannot_access')
      redirect_to authenticated_root_path
    end
  end
end

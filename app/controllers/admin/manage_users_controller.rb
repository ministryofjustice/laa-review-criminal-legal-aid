module Admin
  class ManageUsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_user_manager!

    layout 'manage_users'

    # Scope for I18n locale, used by _text helpers.
    def text_namespace
      :manage_users
    end

    private

    def require_user_manager!
      return if current_user.can_manage_others?

      redirect_to not_found_path
    end
  end
end

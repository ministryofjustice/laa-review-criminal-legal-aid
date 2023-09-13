module ManageUsers
  class BaseController < ApplicationController
    layout 'manage_users'

    before_action :authenticate_user!
    before_action :require_user_manager!
    before_action :set_security_headers

    # Scope for I18n locale, used by _text helpers.
    def text_namespace
      :manage_users
    end

    private

    def require_user_manager!
      return if current_user.can_manage_others?

      render status: :not_found, template: 'errors/not_found', layout: 'external'
      false
    end
  end
end

module ManageCompetencies
  class BaseController < ApplicationController
    layout 'manage_competencies'

    before_action :authenticate_user!
    before_action :require_competency_manager!
    before_action :set_security_headers

    # Scope for I18n locale, used by _text helpers.
    def text_namespace
      :manage_competencies
    end

    private

    def require_competency_manager!
      return if current_user.can_manage_competencies?

      raise ForbiddenError, 'Must be a supervisor or business support user'
    end

    def user_scope
      scope = User.active.where(role: [Types::CASEWORKER_ROLE, Types::SUPERVISOR_ROLE, Types::BUSINESS_SUPPORT_ROLE])

      return scope if FeatureFlags.allow_user_managers_service_access.enabled?

      scope.where(can_manage_others: false)
    end
  end
end

module ManageCompetencies
  class BaseController < ApplicationController
    layout 'manage_competencies'

    before_action :authenticate_user!
    before_action :require_supervisor!
    before_action :set_security_headers

    # Scope for I18n locale, used by _text helpers.
    def text_namespace
      :manage_competencies
    end

    private

    def require_supervisor!
      return if current_user.role == Types::SUPERVISOR_ROLE

      raise ForbiddenError, 'Must be a supervisor'
    end
  end
end

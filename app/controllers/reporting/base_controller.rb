module Reporting
  class BaseController < ApplicationController
    layout 'reporting'

    before_action :authenticate_user!
    before_action :set_security_headers

    private

    def set_report_type
      @report_type = params.require(:report_type).presence_in(*Types::Report)
    end

    def require_dashboard_access!
      return if current_user.can_access_reporting_dashboard?

      raise ForbiddenError, 'Must be a reporting user'
    end

    def require_report_access!
      raise Reporting::ReportNotFound unless current_user.reports.include?(@report_type)
    end
  end
end

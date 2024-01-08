module Reporting
  class BaseController < ApplicationController
    layout 'reporting'

    before_action :authenticate_user!
    before_action :set_security_headers

    private

    def require_dashboard_access!
      return if current_user.can_access_reporting_dashboard?

      raise ForbiddenError, 'Must be a reporting user'
    end

    def require_download_access!
      return if current_user.can_download_reports?

      raise ForbiddenError, 'Cannot download reports'
    end

    def require_report_access!
      return if current_user.reports.include?(@report_type)

      raise ForbiddenError, 'Cannot access this report type'
    end
  end
end

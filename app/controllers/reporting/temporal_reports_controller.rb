module Reporting
  class TemporalReportsController < Reporting::BaseController
    before_action :set_report_type
    before_action :set_interval
    before_action :require_report_access!

    def show
      @report = temporal_report_klass.from_param(
        report_type: @report_type, period: params[:period]
      )
    end

    private

    def set_interval
      @interval = params.require(:interval).presence_in(
        *Types::TemporalInterval
      )
    end

    def temporal_report_klass
      case @interval
      when 'day'
        Reporting::DailyReport
      when 'week'
        Reporting::WeeklyReport
      when 'month'
        Reporting::MonthlyReport
      end
    end
  end
end

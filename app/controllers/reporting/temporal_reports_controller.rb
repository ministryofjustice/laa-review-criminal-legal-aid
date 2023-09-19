module Reporting
  class TemporalReportsController < Reporting::BaseController
    before_action :set_report_type
    before_action :set_interval
    before_action :require_report_access!

    def show
      @report = Reporting.const_get(Types::TemporalInterval[@interval].camelize).from_param(
        report_type: @report_type, period: params[:period]
      )
    end

    private

    def set_interval
      @interval = params.require(:interval).presence_in(
        *Types::TemporalInterval
      )
    end
  end
end

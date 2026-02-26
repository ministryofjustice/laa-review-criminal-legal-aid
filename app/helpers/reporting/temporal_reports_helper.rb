module Reporting
  module TemporalReportsHelper
    def format_percentage(value)
      "#{value}%" if value
    end

    def link_to_unassigned_from_user(data_row, report)
      count = data_row.total_unassigned_from_user

      return count if count.zero?

      govuk_link_to(
        count,
        reporting_unassigned_from_self_report_path(
          interval: report.to_param[:interval],
          period: report.to_param[:period],
          user_id: data_row.user_id
        ),
        no_visited_state: true
      )
    end
  end
end

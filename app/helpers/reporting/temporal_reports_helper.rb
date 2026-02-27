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
        unassigned_from_self_report_path(data_row, report),
        no_visited_state: true,
        visually_hidden_text: "view #{data_row.user_name} unassigned from self",
        data: { turbo: false }
      )
    end

    private

    def unassigned_from_self_report_path(data_row, report)
      reporting_caseworker_temporal_report_path(
        report.to_param.merge(report_type: 'unassigned_from_self_report', user_id: data_row.user_id)
      )
    end
  end
end

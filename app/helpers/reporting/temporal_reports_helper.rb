module Reporting
  module TemporalReportsHelper
    def format_percentage(value)
      "#{value}%" if value
    end

    def link_to_unassigned_from_user(data_row, report)
      count = data_row.unassigned_from_user

      return count unless FeatureFlags.unassigned_from_self_report.enabled?
      return count if count.zero?

      govuk_link_to(
        count,
        unassigned_from_self_report_path(data_row, report),
        no_visited_state: true,
        visually_hidden_text: "view #{data_row.user_name} unassigned from self",
        data: { turbo: false }
      )
    end

    def link_to_search_by_caseworker(user_name, user_id)
      govuk_link_to(
        user_name,
        search_by_caseworker_path(user_id),
        data: { turbo: false },
        no_visited_state: true
      )
    end

    private

    def search_by_caseworker_path(user_id)
      filter = { assigned_status: user_id, application_status: 'open' }
      search_application_searches_path(filter:)
    end

    def unassigned_from_self_report_path(data_row, report)
      reporting_user_temporal_report_path(
        report.to_param.merge(report_type: 'unassigned_from_self_report', user_id: data_row.user_id)
      )
    end
  end
end

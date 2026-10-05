module Reporting
  require 'csv'

  # Reports on applications selected for post-submission slipstream audit in a
  # given month, sourced from the Datastore `/reporting/slipstream_audit`
  # endpoint. Filtering by offence and selection reason, and sorting, happen
  # in-app, as the Datastore endpoint returns the full (small) monthly sample
  # rather than a paginated search result.
  class SlipstreamAuditReport
    CSV_LIMIT = 5_000
    CSV_COLUMNS = %w[
      reference office_code offences sample_rate sampled_at submitted_at
      maat_reference ioj_outcome selection_reason
    ].freeze

    include Downloadable
    include DatastoreApi::Traits::ApiRequest

    attr_reader :time_period, :sorting, :offence, :selection_reason

    def initialize(time_period:, sorting: {}, offence: nil, selection_reason: nil)
      @time_period = time_period
      @sorting = SlipstreamAuditReportSorting.new_or_default(sorting)
      @offence = offence.presence
      @selection_reason = selection_reason.presence
    end

    def rows
      @rows ||= sort_rows(filter_rows(dataset))
    end

    def total_count
      rows.size
    end

    # Distinct offence names present in this month's sample, used to populate
    # the offence filter dropdown.
    def offence_options
      offence_sampling.map { |entry| entry.fetch('offence') }.uniq.sort
    end

    def selection_reason_options
      Types::SlipstreamAuditSelectionReason.values
    end

    def filtered?
      offence.present? || selection_reason.present?
    end

    def csv(*)
      CSV.generate do |csv|
        csv << CSV_COLUMNS
        rows.each { |row| csv << CSV_COLUMNS.map { |column| csv_value(row.public_send(column)) } }
      end
    end

    class << self
      def for_time_period(time_period:, sorting: {}, offence: nil, selection_reason: nil, **)
        new(time_period:, sorting:, offence:, selection_reason:)
      end
    end

    private

    def csv_value(value)
      return value.pluck('name').join('; ') if value.is_a?(Array)

      value
    end

    def response
      @response ||= http_client.get("/reporting/slipstream_audit/monthly/#{period}")
    end

    # Only applications with both a MAAT reference and an IoJ outcome are reportable.
    def dataset
      response.fetch('data')
              .map { |entry| SlipstreamAuditReportRow.new(entry) }
              .select { |row| row.maat_reference.present? && row.ioj_outcome.present? }
    end

    def offence_sampling
      response.fetch('offence_sampling', [])
    end

    def period
      time_period.starts_on.strftime(Reporting::MonthlyReport::PARAM_FORMAT)
    end

    def filter_rows(data)
      data = data.select { |row| row.offence_names.include?(offence) } if offence
      data = data.select { |row| row.selection_reason == selection_reason } if selection_reason
      data
    end

    def sort_rows(data)
      sorted = data.sort_by { |row| sort_key(row) }
      sorting.sort_direction == 'descending' ? sorted.reverse : sorted
    end

    # Returns a [nil-last-flag, value] tuple so nil values (e.g. an
    # undetermined ioj_outcome) sort consistently without raising a
    # comparison error against non-nil values of the same column.
    def sort_key(row)
      value = row.public_send(sorting.sort_by)
      value = value.upcase if value.respond_to?(:upcase)

      [value.nil? ? 1 : 0, value.nil? ? '' : value]
    end
  end
end

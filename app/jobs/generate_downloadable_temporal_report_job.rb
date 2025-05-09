class GenerateDownloadableTemporalReportJob < ApplicationJob
  queue_as :reports

  def perform(report_type, interval) # rubocop:disable Metrics/MethodLength
    report = Reporting::TemporalReport.klass_for_interval(interval).new(
      time_period: previous_time_period(interval:),
      report_type: report_type
    )

    io = StringIO.new(report.csv)
    io.set_encoding('UTF-8')

    GeneratedReport.create!(
      report_type: report_type,
      interval: interval,
      period_start_date: report.time_period.starts_on,
      period_end_date: report.time_period.ends_on,
      report: {
        io: io,
        filename: "#{report_type}_#{interval}_#{report.period_as_param}.csv",
        content_type: 'text/csv'
      }
    )
  end

  private

  def previous_time_period(interval:, date: Time.current)
    previous_date =
      case interval
      when 'monthly' then date.last_month
      when 'weekly' then date.last_week
      when 'daily' then date.yesterday
      end

    Reporting::TimePeriod.new(interval: interval, date: previous_date)
  end
end

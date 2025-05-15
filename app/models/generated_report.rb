class GeneratedReport < ApplicationRecord
  has_one_attached :report

  default_scope { order(created_at: :desc) }

  scope :by_temporal_report, lambda { |report|
    where(
      report_type: report.report_type,
      interval: report.time_period.interval,
      period_start_date: report.time_period.starts_on,
      period_end_date: report.time_period.ends_on
    ).order(created_at: :desc)
  }
end

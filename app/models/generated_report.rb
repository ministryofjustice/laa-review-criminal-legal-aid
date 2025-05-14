class GeneratedReport < ApplicationRecord
  has_one_attached :report

  default_scope { order(created_at: :desc) }

  def period
    format = Reporting::TemporalReport.klass_for_interval(interval)::PERIOD_NAME_FORMAT
    period_start_date.strftime(format)
  end
end

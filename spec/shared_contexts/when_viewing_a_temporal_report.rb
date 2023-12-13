RSpec.shared_context 'when viewing a temporal report' do
  include_context 'with resubmitted application'

  let(:current_user_role) { UserRole::DATA_ANALYST }
  let(:report_type) { Types::TemporalReportType['caseworker_report'] }

  before do
    visit reporting_temporal_report_path(
      interval:, report_type:, period:
    )
  end
end

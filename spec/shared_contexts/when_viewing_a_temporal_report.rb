RSpec.shared_context 'when viewing a temporal report' do
  include_context 'with an existing application'

  let(:current_user_role) { UserRole::DATA_ANALYST }
  let(:report_type) { Types::TemporalReportType['caseworker_report'] }

  before do
    travel_to(Time.zone.local(2023, 1, 1))

    user = User.create!(
      first_name: 'Fred',
      last_name: 'Smitheg',
      auth_oid: '976658f9-f3d5-49ec-b0a9-485ff8b308fa',
      email: 'Fred.Smitheg@justice.gov.uk'
    )

    Assigning::AssignToUser.new(
      user_id: user.id,
      to_whom_id: user.id,
      assignment_id: crime_application_id
    ).call

    travel_to(Time.zone.local(2023, 1, 2))

    visit reporting_temporal_report_path(
      interval:, report_type:, period:
    )
  end
end

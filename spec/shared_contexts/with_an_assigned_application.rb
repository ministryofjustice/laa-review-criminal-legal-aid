RSpec.shared_context 'with an assigned application', shared_context: :metadata do
  include_context 'with an existing application'

  let(:confirm_path) do
    new_crime_application_reassign_path(crime_application_id)
  end

  let(:assignee) do
    User.create(
      first_name: 'Fred',
      last_name: 'Smitheg',
      auth_oid: SecureRandom.uuid,
      email: 'Fred.Smitheg@justice.gov.uk'
    )
  end

  before do
    Assigning::AssignToUser.new(
      user_id: assignee.id,
      to_whom_id: assignee.id,
      assignment_id: crime_application_id,
      reference: 120_398_120
    ).call

    visit '/'
  end
end

RSpec.shared_context 'with a logged in user', shared_context: :metadata do
  before do
    current_user
    visit '/'
    click_button 'Start now'
    select current_user.email
    click_button 'Sign in'
  end

  let(:current_user) do
    User.create(
      email: 'Joe.EXAMPLE@justice.gov.uk',
      first_name: 'Joe',
      last_name: 'EXAMPLE',
      auth_subject_id: current_user_auth_subject_id,
      first_auth_at: 1.month.ago,
      last_auth_at: 1.hour.ago,
      can_manage_others: current_user_can_manage_others,
      role: current_user_role
    )
  end

  let(:current_user_can_manage_others) { false }

  let(:current_user_role) { UserRole::CASEWORKER }

  let(:current_user_id) { current_user.id }

  let(:current_user_auth_subject_id) { SecureRandom.uuid }
end

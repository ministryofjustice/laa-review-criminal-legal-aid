RSpec.shared_context 'with a logged in user', shared_context: :metadata do
  include Devise::Test::IntegrationHelpers

  before do
    sign_in(current_user)
  end

  let(:current_user) do
    User.create(
      email: 'Joe.EXAMPLE@justice.gov.uk',
      first_name: 'Joe',
      last_name: 'EXAMPLE',
      auth_subject_id: current_user_auth_subject_id
    )
  end

  let(:current_user_id) { current_user.id }

  let(:current_user_auth_subject_id) do
    'c0020ca2-a412-4c4e-9aab-6de9c6aed52a'
  end
end

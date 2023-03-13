RSpec.shared_context 'with a logged in user', shared_context: :metadata do
  before do
    auth_hash = OmniAuth::AuthHash.new(
      {
        provider: 'azure_ad',
        uid: current_user_auth_subject_id,
        info: {
          email: current_user.email,
          first_name: current_user.first_name,
          last_name: current_user.last_name
        },
        credentials: {
          expires_at: 1.minute.from_now.to_i
        }
      }
    )

    OmniAuth.config.mock_auth[:azure_ad] = auth_hash
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

  let(:logged_in_user) do
    User.create_by(email: 'Joe.EXAMPLE@justice.gov.uk')
  end

  let(:current_user_auth_subject_id) do
    'c0020ca2-a412-4c4e-9aab-6de9c6aed52a'
  end
end

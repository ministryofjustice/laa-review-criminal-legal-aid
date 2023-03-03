RSpec.shared_context 'with a logged in user', shared_context: :metadata do
  before do
    User.find_or_create_by(id: current_user_id, email: 'Joe.EXAMPLE@justice.gov.uk')

    auth_hash = OmniAuth::AuthHash.new(
      {
        provider: 'azure_ad',
        uid: current_user_auth_oid,
        info: {
          auth_oid: SecureRandom.uuid,
          auth_subject_id: current_user_auth_subject_id,
          email: 'Joe.EXAMPLE@justice.gov.uk',
          first_name: 'Joe',
          last_name: 'EXAMPLE'
        }
      }
    )

    OmniAuth.config.mock_auth[:azure_ad] = auth_hash
  end

  let(:current_user_auth_oid) do
    SecureRandom.uuid
  end

  let(:current_user_id) { SecureRandom.uuid }

  let(:current_user_auth_subject_id) do
    'c0020ca2-a412-4c4e-9aab-6de9c6aed52a'
  end
end

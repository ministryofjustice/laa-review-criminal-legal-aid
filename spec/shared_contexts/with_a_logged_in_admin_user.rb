RSpec.shared_context 'with a logged in admin user', shared_context: :metadata do
  before do
    User.find_or_create_by(
      email: 'Joe.ADMIN_EXAMPLE@justice.gov.uk',
      can_manage_others: true
    )

    auth_hash = OmniAuth::AuthHash.new(
      {
        provider: 'azure_ad',
        uid: current_user_auth_oid,
        info: {
          auth_oid: SecureRandom.uuid,
          auth_subject_id: current_user_auth_subject_id,
          email: 'Joe.ADMIN_EXAMPLE@justice.gov.uk',
          first_name: 'Joe',
          last_name: 'ADMIN_EXAMPLE'
        }
      }
    )

    OmniAuth.config.mock_auth[:azure_ad] = auth_hash
  end

  let(:current_user_auth_oid) do
    SecureRandom.uuid
  end

  let(:current_user_auth_subject_id) do
    SecureRandom.uuid
  end
end

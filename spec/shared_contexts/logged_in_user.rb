RSpec.shared_context 'with a logged in user', shared_context: :metadata do
  before do
    auth_hash = OmniAuth::AuthHash.new(
      {
        provider: 'azure_ad',
        uid: current_user_auth_oid,
        info: {
          auth_oid: current_user_auth_oid,
          email: 'Joe.EXAMPLE@justice.gov.uk',
          first_name: 'Joe',
          last_name: 'EXAMPLE',
          roles: ['caseworker']
        }
      }
    )

    OmniAuth.config.mock_auth[:azure_ad] = auth_hash
  end

  let(:current_user_auth_oid) do
    'c0020ca2-a412-4c4e-9aab-6de9c6aed52a'
  end
end

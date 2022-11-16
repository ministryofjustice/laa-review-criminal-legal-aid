RSpec.shared_context 'with a logged in user', shared_context: :metadata do
  before do
    auth_hash = OmniAuth::AuthHash.new(
      {
        provider: 'azure_ad',
        uid: current_user_id,
        info: user_for_auth.to_hash
      }
    )

    OmniAuth.config.mock_auth[:azure_ad] = auth_hash
  end

  let(:current_user_id) do
    user_for_auth.id
  end

  let(:user_for_auth) do
    User.new(
      id: SecureRandom.hex,
      email: 'Joe.EXAMPLE@justice.gov.uk',
      first_name: 'Joe',
      last_name: 'EXAMPLE',
      roles: ['caseworker']
    )
  end
end

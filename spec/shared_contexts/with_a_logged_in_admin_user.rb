RSpec.shared_context 'with a logged in admin user', shared_context: :metadata do
  include_context 'with a logged in user'

  let(:current_user) do
    User.create(
      email: 'Joe.ADMIN_EXAMPLE@justice.gov.uk',
      first_name: 'Joe',
      last_name: 'ADMIN_EXAMPLE',
      auth_subject_id: current_user_auth_subject_id,
      auth_oid: SecureRandom.uuid,
      can_manage_others: true
    )
  end
end

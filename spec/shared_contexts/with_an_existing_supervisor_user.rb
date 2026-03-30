RSpec.shared_context 'with an existing supervisor user', shared_context: :metadata do
  include Devise::Test::IntegrationHelpers

  let(:supervisor_user) do
    User.create!(
      first_name: 'Zoe',
      last_name: 'Blogs',
      email: "supervisor-#{SecureRandom.hex(4)}@example.com",
      auth_subject_id: SecureRandom.uuid,
      can_manage_others: false,
      role: UserRole::SUPERVISOR
    )
  end
end

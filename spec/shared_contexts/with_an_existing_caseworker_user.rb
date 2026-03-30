RSpec.shared_context 'with an existing caseworker user', shared_context: :metadata do
  let(:caseworker_user) do
    User.create!(
      first_name: 'Case',
      last_name: 'Worker',
      email: "caseworker-#{SecureRandom.hex(4)}@example.com",
      auth_subject_id: SecureRandom.uuid,
      can_manage_others: false,
      first_auth_at: 4.days.ago,
      last_auth_at: 4.days.ago,
      role: UserRole::CASEWORKER
    )
  end
end

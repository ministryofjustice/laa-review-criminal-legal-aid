RSpec.shared_context 'with an existing user', shared_context: :metadata do
  let(:active_user) { user }

  let(:user) do
    User.create!(
      first_name: 'Zoe',
      last_name: 'Blogs',
      email: 'Zoe.Blogs@example.com',
      auth_subject_id: SecureRandom.uuid,
      can_manage_others: user_can_manage_others
    )
  end

  let(:user_can_manage_others) { false }

  let(:user_row) do
    find(
      :xpath,
      "//table[@class='govuk-table']//tr[contains(td[2], '#{user.email}')]"
    )
  end
end

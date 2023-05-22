RSpec.shared_context 'with an existing user', shared_context: :metadata do
  let(:active_user) { user }
  let(:confirm_path) { new_admin_manage_user_deactivate_users_path(active_user) }

  let(:user) do
    User.create!(
      first_name: 'Zoe',
      last_name: 'Blogs',
      email: 'Zoe.Blogs@example.com',
      auth_subject_id: SecureRandom.uuid
    )
  end

  let(:user_row) do
    find(
      :xpath,
      "//table[@class='govuk-table']//tr[contains(td[1], '#{user.email}')]"
    )
  end
end

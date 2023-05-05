RSpec.shared_context 'when logged in user is admin', shared_context: :metadata do
  before do
    current_user.update(can_manage_others: true)
  end
end

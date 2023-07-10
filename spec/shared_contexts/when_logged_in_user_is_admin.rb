RSpec.shared_context 'when logged in user is admin', shared_context: :metadata do
  let(:current_user_can_manage_others) { true }
end

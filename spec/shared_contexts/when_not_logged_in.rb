RSpec.shared_context 'when not logged in', shared_context: :metadata do
  before do
    click_on 'Sign out'
    visit '/'
  end
end

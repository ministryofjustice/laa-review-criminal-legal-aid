# Option 1: Shared example for single accessibility spec file
RSpec.shared_examples 'Accessible' do |page_to_test|
  # include_context 'with a logged in user'
  before { driven_by(:headless_chrome) }

  let(:current_page) { page_to_test }

  it 'and the page is axe accessible' do
    visit page_to_test
    expect(page).to be_axe_clean.according_to :wcag2a, :wcag2aa
  end
end

# Option 2: Shared example for integrating into existing spec files
RSpec.shared_examples 'Is AXE accessible' do
  before { driven_by(:headless_chrome) }

  it 'and the page is axe accessible' do
    expect(page).to be_axe_clean.according_to :wcag2a, :wcag2aa
  end
end
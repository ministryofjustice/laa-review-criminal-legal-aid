require 'rails_helper'

#Option 1: Having a single accessibility test file
RSpec.describe 'Accessibility' do
  include_context 'with a logged in user'
  before { driven_by(:headless_chrome) }
  it_behaves_like 'Accessible', '/'
  it_behaves_like 'Accessible', '/application_searches/new'
  it_behaves_like 'Accessible', '/admin/manage_users'
  it_behaves_like 'Accessible', '/applications/open'
  it_behaves_like 'Accessible', '/applications/closed'

  # Can put in describe blocks for readability?
  describe 'Assigned applications page' do
    it_behaves_like 'Accessible', '/'
  end
end

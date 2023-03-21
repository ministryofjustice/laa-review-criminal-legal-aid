require 'rails_helper'

RSpec.describe 'Viewing an application that is assigned to me' do
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
    visit '/'
    visit crime_application_path(application_id)
    click_button 'Assign to myself'
  end

  it 'includes the name of the assigned user' do
    expect(page).to have_content('Assigned to: Joe EXAMPLE')
  end

  it 'includes button to unassign' do
    expect(page).to have_content('Remove from your list')
  end

  it 'shows the Reviwing buttons' do
    expect(page).to have_content('Mark as complete')
  end

  # it_behaves_like 'Accessible'
end

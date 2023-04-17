require 'rails_helper'

RSpec.describe 'Viewing an application that is assigned to me' do
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
    visit '/'
    visit crime_application_path(application_id)
    click_button 'Assign to your list'
  end

  it 'includes the name of the assigned user' do
    expect(page).to have_content('Assigned to: Joe EXAMPLE')
  end

  it 'includes button to unassign' do
    expect(page).to have_content('Remove from your list')
  end

  describe 'Conditional display of review buttons' do
    it 'displays mark as ready button as default' do
      expect(page).to have_content('Mark as ready')
      expect(page).not_to have_content('Mark as completed')
    end

    context 'when the application is already marked as ready' do
      before do
        allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
          .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

        click_button 'Mark as ready'
        visit crime_application_path(application_id)
      end

      it 'displays mark as completed button if application is marked as ready' do
        expect(page).to have_content('Mark as completed')
        expect(page).not_to have_content('Mark as ready')
      end
    end
  end
end

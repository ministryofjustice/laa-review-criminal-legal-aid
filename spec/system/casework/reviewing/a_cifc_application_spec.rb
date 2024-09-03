require 'rails_helper'

RSpec.describe 'Reviewing a CIFC application' do
  include_context 'with stubbed application'

  let(:application_id) { '98ab235c-f125-4dcb-9604-19e81782e53b' }
  let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'change_in_financial_circumstances').read) }

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new).and_return(
      instance_double(DatastoreApi::Requests::UpdateApplication, call: {})
    )

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
  end

  it 'can be completed by the caseworker' do
    expect(page).to have_content('Change in financial circumstances')
    click_button 'Mark as ready for MAAT'
    click_button 'Mark as completed'
    expect(page).to have_content('You marked the application as complete')
  end
end

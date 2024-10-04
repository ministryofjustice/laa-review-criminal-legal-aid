require 'rails_helper'

RSpec.describe 'Reviewing a PSE application' do
  include_context 'with stubbed application'

  let(:application_id) { '21c37e3e-520f-46f1-bd1f-5c25ffc57d70' }

  let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'post_submission_evidence').read) }

  before do
    allow(FeatureFlags).to receive(:adding_decisions) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: false)
    }

    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new).and_return(
      instance_double(DatastoreApi::Requests::UpdateApplication, call: {})
    )

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
  end

  it 'can be completed by the caseworker' do
    expect(page).not_to have_button('Send back to provider')
    click_button 'Mark as completed'
    expect(page).to have_content('You marked the application as complete')
  end
end

require 'rails_helper'

RSpec.describe 'Adding a decision by MAAT reference' do
  include DecisionFormHelpers

  include_context 'with stubbed application'

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
      .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

    allow(FeatureFlags).to receive(:adding_decisions) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    click_button 'Mark as ready for MAAT'
  end

  it 'informs that the application must be added to MAAT' do
    expect(page).to have_selector 'h2', text: 'Funding decision'
    expect(page).to have_selector 'p',
                                  text: 'First you will need to create an application on MAAT using the reference number (USN) 6000001'
  end

  context 'when an application for the reference is not found on MAAT' do
    let(:mock_get_decision) { instance_double(Maat::GetDecision) }

    before do
      allow(mock_get_decision).to receive(:by_usn).with(6_000_001).and_return(nil)
      allow(Maat::GetDecision).to receive(:new).and_return(mock_get_decision)
    end

    it 'informs the caseworker and redirects them add by MAAT ID' do
      click_button 'Add funding decision from MAAT'

      expect(page).to have_notification_banner(
        text: "Couldn't find the application on MAAT using the reference number (USN) 6000001",
        details: "Enter the MAAT ID of this application here and we'll use that instead of the reference number"
      )

      expect(current_path).to eq('/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/maat_decisions/new')
    end
  end

  context 'when an application for the reference is not found on MAAT' do
    let(:mock_get_decision) { instance_double(Maat::GetDecision) }
    let(:maat_decision) do
      Maat::Decision.new(
        maat_id: 999_333,
        reference: 6_000_001,
        interests_of_justice: {
          result: 'pass',
          assessed_by: 'Jo Bloggs',
          assessed_on:  1.day.ago.to_s
        },
        means: {
          result: 'pass',
          assessed_by: 'Jo Bloggs',
          assessed_on:  1.day.ago.to_s
        },
        funding_decision: 'granted'
      )
    end

    before do
      allow(mock_get_decision).to receive(:by_usn).with(6_000_001).and_return(maat_decision)
      allow(Maat::GetDecision).to receive(:new).and_return(mock_get_decision)
    end

    it 'informs the caseworker and redirects them add by MAAT ID' do
      click_button 'Add funding decision from MAAT'

      expect(page).to have_success_notification_banner(
        text: 'Linked to MAAT record 999333',
        details: 'Check the decision, and make any required amendments on MAAT.'
      )

      expect(current_path).to eq(
        '/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/decisions/MAAT999333/comment/edit'
      )
    end
  end
end

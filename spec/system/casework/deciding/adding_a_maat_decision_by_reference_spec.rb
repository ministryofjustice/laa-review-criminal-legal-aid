require 'rails_helper'

RSpec.describe 'Adding a decision by MAAT reference' do
  include DecisionFormHelpers

  include_context 'with stubbed application'

  let(:mock_get_decision) { instance_double(Maat::GetDecision) }
  let(:reference) { 6_000_001 }
  let(:maat_decision) { nil }

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
      .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

    allow(FeatureFlags).to receive(:adding_decisions) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }

    if maat_decision.present?
      allow(mock_get_decision).to receive(:by_usn!).with(reference).and_return(maat_decision)
    else
      allow(mock_get_decision).to receive(:by_usn!).with(reference).and_raise(Maat::RecordNotFound)
    end

    allow(Maat::GetDecision).to receive(:new).and_return(mock_get_decision)

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    click_button 'Mark as ready for MAAT'
  end

  it 'informs that the application must be added to MAAT' do
    expect(page).to have_selector 'h2', text: 'Funding decision'
    expect(page).to have_selector(
      'p',
      text: 'To add one or more funding decisions, link the application in MAAT first.'
    )
  end

  context 'when an application for the reference is not found on MAAT' do
    it 'informs the caseworker and redirects them to add by MAAT ID' do
      click_button 'Add funding decision from MAAT'

      expect(page).to have_notification_banner(
        text: 'No MAAT ID found that links to LAA reference number 6000001'
      )
      expect(current_path).to eq('/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/link_maat_id')
    end
  end

  context 'when an application for the reference is found on MAAT' do
    let(:maat_decision) do
      Maat::Decision.new(
        maat_ref: 999_333,
        usn: 6_000_001,
        ioj_result: 'PASS',
        ioj_assessor_name: 'Jo Bloggs',
        app_created_date: 1.day.ago.to_s,
        means_result: 'PASS',
        means_assessor_name: 'Jo Bloggs',
        date_means_created:  1.day.ago.to_s,
        funding_decision: 'GRANTED'
      )
    end

    it 'informs the caseworker and redirects them add by MAAT ID' do
      click_button 'Add funding decision from MAAT'

      expect(page).to have_success_notification_banner(
        text: 'MAAT ID 999333 linked'
      )

      expect(current_path).to eq(
        '/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/decisions/999333/comment'
      )
    end
  end
end

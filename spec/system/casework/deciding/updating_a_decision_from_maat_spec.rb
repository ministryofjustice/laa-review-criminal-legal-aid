require 'rails_helper'

RSpec.describe 'Adding a decision by MAAT reference' do
  include DecisionFormHelpers

  include_context 'with stubbed application'

  let(:mock_get_decision) { instance_double(Maat::GetDecision) }
  let(:missing_prompt) { 'Information missing' }
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
      funding_decision: nil
    )
  end

  let(:reference) { 6_000_001 }

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
      .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

    allow(mock_get_decision).to receive(:by_usn!).with(reference).and_return(maat_decision)

    allow(mock_get_decision).to receive(:by_maat_id!).with(maat_decision.maat_ref).and_return(v2)

    allow(Maat::GetDecision).to receive(:new).and_return(mock_get_decision)

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    click_button 'Mark as ready for MAAT'
    click_button 'Add funding decision from MAAT'
    visit crime_application_path(application_id)
    click_on 'Edit'
    click_on 'Change'
    click_button 'Update from MAAT'
  end

  context 'when nothing has changed on MAAT details are missing' do
    let(:v2) { Maat::Decision.new(**maat_decision.attributes) }

    it 'instructs the caseworker to make changes on MAAT' do
      expect(page).to have_notification_banner(
        text: 'The application on MAAT has not changed.',
        details: 'Make any required amendments on MAAT using the MAAT ID 999333.'
      )

      expect(page).to have_notification_banner(
        text: missing_prompt,
        details: 'Complete details in MAAT and then update this page.'
      )
    end
  end

  context 'when changed on MAAT with missing details provided' do
    let(:v2) do
      Maat::Decision.new(**maat_decision.attributes, funding_decision: 'GRANTED')
    end

    it 'instructs the caseworker to check the decision' do
      text = 'Updated from MAAT application with MAAT ID 999333'
      details = 'Check the decision, and make any required amendments on MAAT.'

      expect(page).to have_success_notification_banner(text:, details:)
      expect(page).not_to have_content(missing_prompt)
    end
  end
end

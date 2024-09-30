require 'rails_helper'

RSpec.describe 'Adding a decision by MAAT ID' do
  include DecisionFormHelpers

  include_context 'with stubbed application'

  let(:mock_get_decision) { instance_double(Maat::GetDecision) }
  let(:maat_decision) { nil }

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
      .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

    allow(FeatureFlags).to receive(:adding_decisions) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }

    allow(mock_get_decision).to receive(:by_maat_id).with(maat_id).and_return(maat_decision)
    allow(Maat::GetDecision).to receive(:new).and_return(mock_get_decision)

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    click_button 'Mark as ready for MAAT'
    visit new_crime_application_maat_decision_path(application_id)

    fill_in('MAAT ID', with: maat_id)

    save_and_continue
  end

  context 'when MAAT ID not entered' do
    let(:maat_id) { nil }

    it 'shows an error' do
      expect(page).to have_error(
        'MAAT ID', 'Enter the MAAT ID of the corresponding application on MAAT'
      )
    end
  end

  context 'when MAAT ID less than the starting MAAT ID' do
    let(:maat_id) { 2 }

    it 'shows an error' do
      expect(page).to have_error(
        'MAAT ID', 'Enter the MAAT ID of the corresponding application on MAAT'
      )
    end
  end

  context 'when an application for the reference is found on MAAT' do
    let(:maat_id) { 123 }

    let(:maat_decision) do
      Maat::Decision.new(
        maat_id: maat_id,
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

    it 'creates the decision and shows the success message' do
      expect(page).to have_success_notification_banner(
        text: 'Linked to MAAT application with MAAT ID 123',
        details: 'Check the decision, and make any required amendments on MAAT.'
      )

      expect(current_path).to eq(
        "/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/decisions/#{maat_id}/comment/edit"
      )
    end
  end

  context 'when found MAAT application has a different USN' do
    let(:maat_id) { 123 }

    let(:maat_decision) do
      Maat::Decision.new(
        maat_id: maat_id,
        reference: 6_000_002,
        interests_of_justice: nil,
        means: nil,
        funding_decision: nil
      )
    end

    it 'shows an error' do
      expect(page).to have_error(
        'MAAT ID', 'The application on MAAT with this MAAT ID is associated with another reference number (USN)'
      )
    end
  end

  context 'when found MAAT application is already linked' do
    let(:maat_id) { 123 }

    let(:maat_decision) do
      Maat::Decision.new(
        maat_id: maat_id,
        reference: 6_000_001,
        interests_of_justice: nil,
        means: nil,
        funding_decision: nil
      )
    end

    it 'shows an error' do
      visit new_crime_application_maat_decision_path(application_id)
      fill_in('MAAT ID', with: maat_id)
      save_and_continue

      expect(page).to have_error(
        'MAAT ID', 'This MAAT ID is already linked'
      )
    end
  end
end

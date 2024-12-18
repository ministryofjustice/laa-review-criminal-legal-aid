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

    allow(mock_get_decision).to receive(:by_maat_id!).with(maat_id).and_return(maat_decision)
    allow(Maat::GetDecision).to receive(:new).and_return(mock_get_decision)

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    click_button 'Mark as ready for MAAT'
    visit crime_application_link_maat_id_path(application_id)

    fill_in('MAAT ID', with: maat_id)

    save_and_continue
  end

  context 'when MAAT ID not entered' do
    let(:maat_id) { nil }

    it 'shows an error' do
      expect(page).to have_error(
        'MAAT ID', 'Enter a valid MAAT ID'
      )
    end
  end

  context 'when MAAT ID less than the starting MAAT ID' do
    let(:maat_id) { 2 }

    it 'shows an error' do
      expect(page).to have_error(
        'MAAT ID', 'Enter a valid MAAT ID'
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
          result: 'fail',
          assessed_by: 'Jo Blogs',
          assessed_on:  Date.new(2024, 2, 1)
        },
        means: {
          result: 'fail',
          assessed_by: 'Jan Blogs',
          assessed_on:  Date.new(2024, 2, 2)
        },
        funding_decision: 'failmeioj'
      )
    end

    it 'creates the decision and shows the success message' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
      expect(page).to have_success_notification_banner(
        text: 'MAAT ID 123 linked'
      )

      expect(summary_card('Case')).to have_rows(
        'Interests of justice (IoJ) test result', 'Refused',
        'IoJ comments', '',
        'IoJ caseworker', 'Jo Blogs',
        'IoJ test date', '01/02/2024',
        'Means test result', 'Failed',
        'Means test caseworker', 'Jan Blogs',
        'Means test date', '02/02/2024',
        'Overall result', 'Failed means and IoJ'
      )

      expect(current_path).to eq(
        "/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a/decisions/#{maat_id}/comment"
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
        'MAAT ID', 'This MAAT ID is linked to another LAA reference number'
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
      visit crime_application_link_maat_id_path(application_id)
      fill_in('MAAT ID', with: maat_id)
      save_and_continue

      expect(page).to have_error(
        'MAAT ID', 'This MAAT ID is already linked'
      )
    end
  end
end

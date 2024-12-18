require 'rails_helper'

RSpec.describe 'Adding another MAAT decision' do
  include DecisionFormHelpers

  include_context 'with stubbed application'

  let(:mock_get_decision) { instance_double(Maat::GetDecision) }
  let(:maat_id) { 12_312_345 }
  let(:maat_id2) { 12_312_347 }

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

  let(:maat_decision2) do
    Maat::Decision.new(
      maat_id: maat_id2,
      reference: nil,
      interests_of_justice: {
        result: 'pass',
        assessed_by: 'Jo Bloggs',
        assessed_on:  1.hour.ago.to_s
      },
      means: {
        result: 'fail',
        assessed_by: 'Jo Bloggs',
        assessed_on:  1.hour.ago.to_s
      },
      funding_decision: 'failmeans'
    )
  end

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
      .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

    allow(FeatureFlags).to receive(:adding_decisions) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }

    allow(mock_get_decision).to receive(:by_maat_id!).with(maat_id).and_return(maat_decision)
    allow(mock_get_decision).to receive(:by_maat_id!).with(maat_id2).and_return(maat_decision2)
    allow(Maat::GetDecision).to receive(:new).and_return(mock_get_decision)

    visit crime_application_path(application_id)
    click_button 'Assign to your list'
    click_button 'Mark as ready for MAAT'
    visit crime_application_link_maat_id_path(application_id)

    fill_in('MAAT ID', with: maat_id)
    save_and_continue
    complete_comment_form
    choose_answer('What do you want to do next?', 'Add another MAAT ID')
    save_and_continue
    fill_in('MAAT ID', with: maat_id2)
    save_and_continue
    complete_comment_form
  end

  it 'adds another case' do # rubocop:disable RSpec/MultipleExpectations
    expect(page).to have_content('You have added 2 cases')
    within_card('Case 1') do |card|
      expect(card).to have_summary_row('MAAT ID', maat_id.to_s)
    end

    within_card('Case 2') do |card|
      expect(card).to have_summary_row('MAAT ID', maat_id2.to_s)
    end
  end

  it 'returns to the decisions page when one of the decisions is removed' do
    within_card('Case 1') { click_button('Remove') }

    expect(page).to have_success_notification_banner(text: 'Decision removed')
    expect(current_path).to eq(crime_application_send_decisions_path(application_id))
  end

  it 'sends the decisions' do
    choose_answer('What do you want to do next?', 'Send to provider')
    save_and_continue

    expect(page).to have_success_notification_banner(text: 'Application complete. Decision sent to provider.')

    expect(current_path).to eq(assigned_applications_path)
  end
end

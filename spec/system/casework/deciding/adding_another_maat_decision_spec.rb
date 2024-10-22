require 'rails_helper'

RSpec.describe 'Adding another MAAT decision' do
  include DecisionFormHelpers

  include_context 'with stubbed application'

  let(:mock_get_decision) { instance_double(Maat::GetDecision) }
  let(:maat_id) { 12312345 }

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
    complete_comment_form
  end

  it 'can choose to add another' do
    choose_answer("Do you want to add another case?", 'Yes')
    save_and_continue
    expect(current_path).to eq(new_crime_application_maat_decision_path(application_id))
  end
  
  it 'can choose not to add another' do
    choose_answer("Do you want to add another case?", 'No')
    save_and_continue

    expect(current_path).to eq(crime_application_path(application_id))
  end
end

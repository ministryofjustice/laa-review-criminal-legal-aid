require 'rails_helper'

RSpec.describe 'Removing a MAAT decision' do
  include DecisionFormHelpers

  include_context 'with stubbed application'

  let(:mock_get_decision) { instance_double(Maat::GetDecision) }
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

  let(:maat_id) { 123 }

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
    click_button('Remove')
  end

  it 'removes the maat decision and redirects to the details page' do
    expect(page).to have_success_notification_banner(
      text: 'Decision removed'
    )

    expect(current_path).to eq(
      '/applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a'
    )
  end

  it 'the removed decision can be re-added' do
    visit crime_application_link_maat_id_path(application_id)
    fill_in('MAAT ID', with: maat_id)
    save_and_continue

    expect(page).to have_success_notification_banner(
      text: "MAAT ID #{maat_id} linked"
    )
  end
end

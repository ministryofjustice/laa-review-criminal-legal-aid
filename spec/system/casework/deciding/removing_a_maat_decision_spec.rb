require 'rails_helper'

RSpec.describe 'Removing a MAAT decision' do
  include DecisionFormHelpers

  include_context 'with stubbed application'
  include_context 'when adding a decision by MAAT ID'

  let(:maat_id) { 123 }
  let(:maat_decision_maat_id) { maat_id }

  before do
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

require 'rails_helper'

RSpec.describe 'Slipstream audit notification banner on decision pages' do
  include DecisionFormHelpers

  let(:current_user_role) { UserRole::CASEWORKER }

  let(:notice_text) do
    'For assurance purposes, Interests of Justice (IOJ) reasons are required for this application.'
  end

  let(:slipstream_audit_selection_outcome) do
    {
      'status' => status,
      'sample_rate' => 10,
      'sampled_at' => '2026-09-03T10:00:00.000Z',
      'status_determined_at' => '2026-09-04T11:00:00.000Z',
      'selection_reason' => 'age'
    }
  end

  include_context 'with stubbed application' do
    let(:application_data) do
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge(
        'is_means_tested' => 'no',
        'work_stream' => 'non_means_tested',
        'slipstream_audit_selection_outcome' => slipstream_audit_selection_outcome
      )
    end

    before do
      allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
        .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

      visit crime_application_path(application_id)
      click_button 'Assign to your list'
    end

    context 'when the application has a confirmed slipstream audit selection' do
      let(:status) { 'confirmed' }

      # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
      it 'shows the banner on every decision page' do
        click_button 'Start'
        expect(page).to have_content(notice_text) # interests of justice

        complete_ioj_form
        expect(page).to have_content(notice_text) # overall result

        complete_overall_result_form
        expect(page).to have_content(notice_text) # comment

        complete_comment_form
        visit crime_application_send_decisions_path(application_id)
        expect(page).to have_content(notice_text) # send decisions
      end
      # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
    end

    context 'when the selection outcome is not confirmed' do
      let(:status) { 'withdrawn' }

      it 'does not show the banner on the decision pages' do
        click_button 'Start'

        expect(page).to have_no_content(notice_text)
      end
    end
  end
end

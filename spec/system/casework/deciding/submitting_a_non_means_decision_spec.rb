require 'rails_helper'

RSpec.describe 'Submitting a Non-means decision' do
  include DecisionFormHelpers

  include_context 'with stubbed application' do
    let(:application_data) do
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge(
        'is_means_tested' => 'no',
        'work_stream' => 'non_means_tested'
      )
    end

    let(:updated_application_data) do
      application_data.merge(
        'decisions' => [
          {
            'reference' => 6_000_001,
            'maat_id' => nil,
            'interests_of_justice' => {
              'result' => 'failed',
              'details' => 'reason',
              'assessed_by' => 'Test User',
              'assessed_on' => '2024-10-01 00:00:00'
            },
            'means' => nil,
            'funding_decision' => 'refused',
            'overall_result' => 'Failed IoJ',
            'comment' => 'Test comment'
          }
        ]
      )
    end

    let(:send_decisions_form_prompt) { 'What do you want to do next?' }

    before do
      allow(FeatureFlags).to receive(:adding_decisions) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }

      allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
        .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

      stub_request(
        :get,
        "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}"
      ).to_return(body: updated_application_data.to_json, status: 200)

      visit crime_application_path(application_id)
      click_button 'Assign to your list'
    end

    it 'shows the confirmation page' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
      add_a_failed_non_means_decision
      expect(page).to have_content('Your list (1)')
      expect(summary_card('Case')).to have_rows(
        'Interests of justice (IoJ) test result', 'Failed',
        'Overall result', 'Failed IoJ'
      )
      choose_answer(send_decisions_form_prompt, 'Send decision to provider')
      save_and_continue

      expect(page).to have_content('Your list (0)')
      expect(page).to have_success_notification_banner(
        text: 'Application complete. Decision sent to provider.'
      )

      visit crime_application_path(application_id)

      # NB: the decision displayed should be that from the datastore
      # not the event sourced decision.
      expect(summary_card('Case')).to have_rows(
        'Interests of justice (IoJ) test result', 'Failed',
        'IoJ comments', 'reason',
        'IoJ caseworker', 'Test User',
        'IoJ test date', '01/10/2024',
        'Overall result', 'Failed IoJ',
        'Comments', 'Test comment'
      )
    end

    context 'when navigating to the send decision page with an incomplete decision' do
      before do
        click_button 'Start'
        complete_ioj_form

        visit crime_application_send_decisions_path(application_id)
      end

      it 'does not show the send decision form' do
        expect(current_path).to eq crime_application_send_decisions_path(application_id)
        expect(page).not_to have_content send_decisions_form_prompt
      end
    end

    context 'when choosing to "save and come back later"' do
      include_context 'with stubbed search'

      before do
        add_a_non_means_decision
        click_on 'Save and come back later'
      end

      it 'redirects to the assigned applications page' do
        expect(current_path).to eq assigned_applications_path
      end
    end

    context 'when "what do you want to do next?" not answered' do
      before do
        add_a_non_means_decision
        save_and_continue
      end

      it 'shows an error message' do
        expect(page).to have_error(
          send_decisions_form_prompt, 'Select what you want to do next'
        )
      end
    end
  end
end

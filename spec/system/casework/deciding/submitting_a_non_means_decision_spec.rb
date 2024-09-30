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
              'result' => 'pass',
              'details' => 'reason',
              'assessed_by' => 'Test User',
              'assessed_on' => '2024-10-01 00:00:00'
            },
            'means' => nil,
            'funding_decision' => 'granted',
            'comment' => 'Test comment'
          }
        ]
      )
    end

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

      add_a_non_means_decision
    end

    it 'shows the confirmation page' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
      expect(page).to have_content('Your list (1)')

      click_on 'Submit decision'

      expect(page).to have_content('Your list (0)')

      expect(page).to have_text('Decision sent')
      expect(summary_card('Case')).to have_rows(
        'Interests of justice test results', 'Passed',
        'Interests of justice reason', 'reason',
        'Interests of justice test caseworker name', 'Test User',
        'Date of interests of justice test', '01/10/2024',
        'Overall result', 'Granted',
        'Further information about the decision', 'Test comment'
      )

      visit crime_application_path(application_id)

      # NB: the decision displayed should be that form the datastore
      # not the event sourced decision.
      expect(summary_card('Case')).to have_rows(
        'Interests of justice test results', 'Passed',
        'Interests of justice reason', 'reason',
        'Interests of justice test caseworker name', 'Test User',
        'Date of interests of justice test', '01/10/2024',
        'Overall result', 'Granted',
        'Further information about the decision', 'Test comment'
      )
    end
  end
end

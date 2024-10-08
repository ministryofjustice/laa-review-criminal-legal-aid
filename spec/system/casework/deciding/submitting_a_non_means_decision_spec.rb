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

      Assigning::AssignToUser.new(
        assignment_id: application_id,
        user_id: current_user_id,
        to_whom_id: current_user_id
      ).call

      decision_id = SecureRandom.uuid

      args = {
        application_id: application_id,
        user_id: current_user_id,
        decision_id: decision_id
      }

      Reviewing::AddDecision.call(**args)
      Deciding::CreateDraft.call(**args)
      Deciding::SetInterestsOfJustice.call(
        decision_id: decision_id,
        user_id: current_user_id,
        result: 'pass',
        details: 'reason',
        assessed_by: 'Test User',
        assessed_on: Date.new(2024, 10, 1)
      )
      Deciding::SetFundingDecision.call(
        decision_id: decision_id,
        user_id: current_user_id,
        funding_decision: 'granted'
      )
      Deciding::SetComment.call(
        decision_id: decision_id,
        user_id: current_user_id,
        comment: 'Test comment'
      )

      visit crime_application_path(application_id)

      stub_request(
        :get,
        "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}"
      ).to_return(body: updated_application_data.to_json, status: 200)
    end

    it 'shows the confirmation page' do # rubocop:disable RSpec/ExampleLength
      click_on 'Submit decision'

      expect(page).to have_text('Decision sent')
      expect(summary_card('Case')).to have_rows(
        'Interests of justice test results', 'Passed',
        'Interests of justice reason', 'reason',
        'Interests of justice test caseworker name', 'Test User',
        'Date of interests of justice test', '01/10/2024',
        'Overall result', 'Granted',
        'Further information about the decision', 'Test comment'
      )
    end

    it 'removes the application from "Your list"' do
      expect(page).to have_content('Your list (1)')

      click_on 'Submit decision'

      expect(page).to have_content('Your list (0)')
    end

    it 'shows funding decision on closed application' do # rubocop:disable RSpec/ExampleLength
      click_on 'Submit decision'
      visit crime_application_path(application_id)

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

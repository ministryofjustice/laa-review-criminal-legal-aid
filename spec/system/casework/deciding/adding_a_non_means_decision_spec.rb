require 'rails_helper'

RSpec.describe 'Adding a Non-means application' do
  include DecisionFormHelpers

  # rubocop:disable RSpec/ExampleLength

  include_context 'with stubbed application' do
    let(:application_data) do
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge(
        'is_means_tested' => 'no',
        'work_stream' => 'non_means_tested'
      )
    end

    before do
      allow(FeatureFlags).to receive(:adding_decisions) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }

      visit crime_application_path(application_id)
      click_button 'Assign to your list'
    end

    it 'informs that a manual decision is required' do
      expect(page).to have_selector 'h2', text: 'Funding decision'
      expect(page).to have_selector 'p', text: 'You need to manually enter a decision for this application.'
    end

    it 'validates the interests of justice form' do
      click_button 'Start'
      save_and_continue

      expect(page).to have_errors(
        'What is the name of the caseworker who assessed this?',
        'Enter the name of the caseworker who assessed this',
        'What is the interests of justice test result?',
        'Select the test result',
        'What is the name of the caseworker who assessed this?',
        'Enter the name of the caseworker who assessed this',
        'Enter the date of assessment', 'Enter the date of assessemnt'
      )
    end

    it 'validates the overall result form' do
      click_button 'Start'
      complete_ioj_form
      save_and_continue

      expect(page).to have_error(
        'What is the funding decision for this application?',
        'Select the funding decision'
      )
    end

    it 'validates the comment form' do
      click_button 'Start'
      complete_ioj_form
      complete_overall_result_form
      save_and_continue

      expect(page).to have_error(
        'Do you need to add comments for the provider?',
        'Select yes if you need to add comments for the provider'
      )

      choose_answer('Do you need to add comments for the provider?', 'Yes')
      save_and_continue

      expect(page).to have_error(
        'Additional comments for the provider',
        'Enter additional comments for the provider'
      )
    end

    it 'A valid draft decisions can be created' do
      add_a_non_means_decision

      expect(summary_card('Case')).to have_rows(
        'Interests of justice test results', 'Passed',
        'Interests of justice reason', 'Test result reason details',
        'Interests of justice test caseworker name', 'Zoe Blogs',
        'Date of interests of justice test', '01/02/2024',
        'Overall result', 'Granted',
        'Further information about the decision', 'Caseworker comment'
      )
    end
  end

  # rubocop:enable RSpec/ExampleLength
end

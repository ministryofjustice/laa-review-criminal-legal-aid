require 'rails_helper'

RSpec.describe 'Adding a Non-means application' do
  include DecisionFormHelpers

  let(:current_user_role) { UserRole::CASEWORKER }

  # rubocop:disable RSpec/ExampleLength
  shared_examples 'hides "Start" button' do
    it 'does not show the "Start" button' do
      expect(page).to have_no_button('Start')
    end
  end

  include_context 'with stubbed application' do
    let(:application_data) do
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge(
        'is_means_tested' => 'no',
        'work_stream' => 'non_means_tested'
      )
    end

    before do
      visit crime_application_path(application_id)
      click_button 'Assign to your list'
    end

    it 'informs that a manual decision is required' do
      expect(page).to have_selector 'h2', text: 'Funding decision'
      expect(page).to have_selector 'p', text: 'You need to manually enter a decision for this application.'
    end

    it 'shows the "Start" button' do
      expect(page).to have_button('Start')
    end

    it 'validates the interests of justice form' do
      click_button 'Start'
      save_and_continue

      expect(page).to have_errors(
        'Caseworker name', 'Enter the caseworker name',
        'Interests of justice test result', 'Select a result for the Interest of justice test',
        'Reason for result', 'Enter a reason for the result',
        'Date of test', 'Enter the date of the test'
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

    it 'A valid draft decisions can be created' do
      add_a_non_means_decision

      expect(summary_card('Case')).to have_rows(
        'Interests of Justice (IOJ) test result', 'Passed',
        'IOJ comments', 'Test result reason details',
        'IOJ caseworker', 'Zoe Blogs',
        'IOJ test date', '01/02/2024',
        'Overall result', 'Granted',
        'Comments', 'Caseworker comment'
      )
    end
  end

  context 'when viewing the application as a non-reviewer' do
    before do
      visit crime_application_path(application_id)
    end

    context 'when a data analyst' do
      let(:current_user_role) { UserRole::DATA_ANALYST }

      include_examples 'hides "Start" button'
    end

    context 'when an auditor' do
      let(:current_user_role) { UserRole::AUDITOR }

      include_examples 'hides "Start" button'
    end
  end

  # rubocop:enable RSpec/ExampleLength
end

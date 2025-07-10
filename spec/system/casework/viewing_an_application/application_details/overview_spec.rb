require 'rails_helper'

RSpec.describe 'When viewing the overview details of an application' do
  include_context 'with stubbed application'

  let(:case_type) { 'summary_only' }

  before do
    visit crime_application_path(application_id)
  end

  context 'when the application is non-means' do
    let(:application_data) do
      super().deep_merge('is_means_tested' => 'no')
    end

    it 'shows the relevant details' do
      expect(summary_card('Overview')).to have_rows(
        'Application type', 'Initial application',
        'Subject to means test?', 'No',
        'Date stamp', '24/10/2022 10:50am',
        'Date submitted', '24/10/2022 10:50am'
      )
    end
  end

  context 'when the application is passported' do
    let(:application_data) do
      super().deep_merge(
        'is_means_tested' => 'yes',
        'means_passport' => ['on_benefit_check'],
        'client_details' => {
          'applicant' => {
            'benefit_type' => 'universal_credit'
          }
        }
      )
    end

    it 'shows the relevant details' do # rubocop:disable RSpec/ExampleLength
      expect(summary_card('Overview')).to have_rows(
        'Application type', 'Initial application',
        'Subject to means test?', 'Yes',
        'Selected passporting benefit?', 'Yes',
        'Unique reference number (URN)', 'None',
        'Date stamp', '24/10/2022 10:50am',
        'Date submitted', '24/10/2022 10:50am',
        'Overall offence class', 'Undetermined'
      )
      expect(summary_card('Overview')).not_to have_content('Unique reference number (URN) None Copy')
    end
  end

  context 'when the application is not passported' do
    let(:application_data) do
      super().deep_merge(
        'is_means_tested' => 'yes',
        'means_passport' => [],
        'client_details' => {
          'applicant' => {
            'benefit_type' => 'none'
          }
        }
      )
    end

    it 'shows the relevant details' do # rubocop:disable RSpec/ExampleLength
      expect(summary_card('Overview')).to have_rows(
        'Application type', 'Initial application',
        'Subject to means test?', 'Yes',
        'Selected passporting benefit?', 'No',
        'Unique reference number (URN)', 'None',
        'Date stamp', '24/10/2022 10:50am',
        'Date submitted', '24/10/2022 10:50am',
        'Overall offence class', 'Undetermined'
      )
    end
  end

  context 'when the application is passported via the partner' do
    let(:application_data) do
      super().deep_merge(
        'is_means_tested' => 'yes',
        'means_passport' => ['on_benefit_check'],
        'client_details' => {
          'applicant' => {
            'benefit_type' => 'none'
          },
          'partner' => {
            'benefit_type' => 'universal_credit'
          }
        }
      )
    end

    it 'shows the relevant details' do # rubocop:disable RSpec/ExampleLength
      expect(summary_card('Overview')).to have_rows(
        'Application type', 'Initial application',
        'Subject to means test?', 'Yes',
        'Selected passporting benefit?', 'Yes - partner',
        'Unique reference number (URN)', 'None',
        'Date stamp', '24/10/2022 10:50am',
        'Date submitted', '24/10/2022 10:50am',
        'Overall offence class', 'Undetermined'
      )
    end
  end

  context 'when the application is CIFC' do
    let(:fixture_name) { 'change_in_financial_circumstances' }

    it 'shows the relevant details' do # rubocop:disable RSpec/ExampleLength
      expect(summary_card('Overview')).to have_rows(
        'Application type', 'Change in financial circumstances',
        "Changes in client's financial circumstances", 'My client has a new job',
        'MAAT ID of original application', '987654321',
        'Subject to means test?', 'Yes',
        'Selected passporting benefit?', 'Yes',
        'Unique reference number (URN)', 'None',
        'Date stamp', '24/10/2022 10:50am',
        'Date submitted', '24/10/2022 10:50am'
      )
    end
  end

  context 'when the application is an appeal to crown court' do
    let(:case_type) { 'appeal_to_crown_court' }

    it 'shows the relevant details' do # rubocop:disable RSpec/ExampleLength
      expect(summary_card('Overview')).to have_rows(
        'Application type', 'Initial application',
        'Subject to means test?', 'Yes',
        'Selected passporting benefit?', 'Yes',
        'Unique reference number (URN)', 'None',
        'Date stamp', '24/10/2022 10:50am',
        'Date submitted', '24/10/2022 10:50am',
        'Overall offence class', 'Undetermined'
      )
    end
  end
end

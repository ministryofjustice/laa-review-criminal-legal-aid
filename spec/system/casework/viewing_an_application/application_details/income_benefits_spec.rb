require 'rails_helper'

RSpec.describe 'Viewing the income benefits of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with income benefit details' do
    it { expect(page).to have_content('Benefits') }

    # rubocop:disable RSpec/MultipleExpectations
    it 'shows income benefit details' do
      expect(page).to have_content('Child Benefit £39.90 every month')
      expect(page).to have_content('Working Tax Credit or Child Tax Credit Does not get')
      expect(page).to have_content('Incapacity Benefit Does not get')
      expect(page).to have_content('Industrial Injuries Disablement Benefit Does not get')
      expect(page).to have_content("Contribution-based Jobseeker's Allowance Does not get")
      expect(page).to have_content('Other benefits £18.84 every 2 weeks')
      expect(page).to have_content("Other benefits details\nTop up")
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context 'with no income benefits details' do
    let(:application_data) do
      super().deep_merge(
        'means_details' => {
          'income_details' => { 'income_benefits' => [], 'has_no_income_benefits' => 'yes' }
        }
      )
    end

    it 'shows income benefit details' do
      expect(page).to have_content('Benefits the client gets None')
    end
  end
end

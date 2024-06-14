require 'rails_helper'

RSpec.describe 'Viewing the income benefits of the partner' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with partner income benefit details' do
    # rubocop:disable Layout/LineLength
    let(:application_data) do
      super().deep_merge('means_details' => { 'income_details' => { 'income_benefits' => [{
                           'payment_type' => 'child',
                                                                                            'amount' => 3990,
                                                                                            'frequency' => 'month',
                                                                                            'ownership_type' => 'partner',
                         }] } })
    end
    # rubocop:enable Layout/LineLength

    it { expect(page).to have_content('Benefits the partner gets') }

    # rubocop:disable RSpec/MultipleExpectations
    it 'shows income benefit details' do
      expect(page).to have_content('Child Benefit £39.90 every month')
      expect(page).to have_content('Working Tax Credit or Child Tax Credit Does not get')
      expect(page).to have_content('Incapacity Benefit Does not get')
      expect(page).to have_content('Industrial Injuries Disablement Benefit Does not get')
      expect(page).to have_content("Contribution-based Jobseeker's Allowance Does not get")
      expect(page).to have_content('Other benefits Does not get')
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context 'with no income benefits details' do
    let(:application_data) do
      super().deep_merge(
        'means_details' => {
          'income_details' => { 'income_benefits' => [], 'partner_has_no_income_benefits' => 'yes' }
        }
      )
    end

    it 'shows income benefit details' do
      expect(page).to have_content('Which benefits does the partner get? None')
    end
  end
end

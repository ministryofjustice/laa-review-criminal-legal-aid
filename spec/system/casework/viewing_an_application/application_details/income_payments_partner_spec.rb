require 'rails_helper'

RSpec.describe 'Viewing the income payments of the partner' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with partner income payments details' do
    let(:application_data) do
      super().deep_merge('means_details' => { 'income_details' => { 'income_payments' => [{
                           'payment_type' => 'private_pension',
                            'amount' => 35_000,
                            'frequency' => 'month',
                            'ownership_type' => 'partner',
                         }] } })
    end

    it { expect(page).to have_content('Payments: partner') }

    # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
    it 'shows income payment details' do
      expect(page).to have_content('Private pensions £350.00 every month')
      expect(page).to have_content('State Pension Does not get')
      expect(page).to have_content('Maintenance payments Does not get')
      expect(page).to have_content('Interest or income from savings or investments Does not get')
      expect(page).to have_content('Student grant or loan Does not get')
      expect(page).to have_content('Board from family members living with the client Does not get')
      expect(page).to have_content('Rent from a tenant Does not get')
      expect(page).to have_content(
        'Financial support from someone who allows the client access to their assets or money Does not get'
      )
      expect(page).to have_content('Money from friends or family Does not get')
      expect(page).to have_content('Other sources of income Does not get')
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
  end

  context 'with no income payments details' do
    let(:application_data) do
      super().deep_merge(
        'means_details' => {
          'income_details' => { 'income_payments' => [], 'partner_has_no_income_payments' => 'yes' }
        }
      )
    end

    it 'shows income payment details' do
      expect(page).to have_content('Payments the partner gets None')
    end
  end
end

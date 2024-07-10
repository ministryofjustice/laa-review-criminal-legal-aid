require 'rails_helper'

RSpec.describe 'Viewing the businesses of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers, RSpec/MultipleExpectations
  context 'when client has savings' do
    let(:has_additional_owners) { 'no' }
    let(:additional_owners) { nil }
    let(:has_employees) { 'no' }
    let(:number_of_employees) { nil }
    let(:salary) { nil }
    let(:total_income_share_sales) { nil }
    let(:percentage_profit_share) { nil }

    let(:self_employed_business) do
      {
        'ownership_type' => 'applicant',
        'business_type' => 'self_employed',
        'trading_name' => 'Self employed business 1',
        'address' => {
          'address_line_one' => 'address_line_one_x',
          'address_line_two' => 'address_line_two_x',
          'city' => 'city_x',
          'postcode' => 'postcode_x',
          'country' => 'country_x'
        },
        'description' => 'A cafe',
        'trading_start_date' => 'Sat, 12 Jun 2021',
        'has_additional_owners' => has_additional_owners,
        'additional_owners' => additional_owners,
        'has_employees' => has_employees,
        'number_of_employees' => number_of_employees,
        'turnover' => {
          'amount' => 78_600,
          'frequency' => 'week'
        },
        'drawings' => {
          'amount' => 93_000,
          'frequency' => 'four_weeks'
        },
        'profit' => {
          'amount' => 12_100,
          'frequency' => 'week'
        },
        'salary' => salary,
        'total_income_share_sales' => total_income_share_sales,
        'percentage_profit_share' => percentage_profit_share,
      }
    end

    let(:application_data) do
      super().deep_merge('means_details' => { 'income_details' => { 'businesses' => [self_employed_business] } })
    end

    it 'shows the business with correct title' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'Self-employed business')
    end

    describe 'a business card' do
      subject(:business_card) do
        page.find('h2.govuk-summary-card__title', text: 'Self-employed business').ancestor('div.govuk-summary-card')
      end

      it 'shows business details' do # rubocop:disable RSpec/ExampleLength
        within(business_card) do |card|
          expect(card).to have_summary_row 'Trading name of business', 'Self employed business 1'
          expect(card).to have_summary_row 'Business address',
                                           'address_line_one_x address_line_two_x city_x postcode_x country_x'
          expect(card).to have_summary_row 'Nature of business', 'A cafe'
          expect(card).to have_summary_row 'Date began trading', '12 Jun 2021'
          expect(card).to have_summary_row 'In business with anyone else', 'No'
          expect(card).to have_no_content 'Name of others in business'
          expect(card).to have_summary_row 'Employees?', 'No'
          expect(card).to have_no_content 'Number of employees'
          expect(card).to have_summary_row 'Total turnover', '£786.00 every week'
          expect(card).to have_summary_row 'Total drawings', '£930.00 every 4 weeks'
          expect(card).to have_summary_row 'Total profit', '£121.00 every week'
        end
      end

      context 'when number of employees information is given' do
        let(:has_employees) { 'yes' }
        let(:number_of_employees) { 9 }

        it 'shows number of employees details' do
          within(business_card) do |card|
            expect(card).to have_summary_row 'Number of employees', '9'
          end
        end
      end

      context 'when additional owner information is given' do
        let(:has_additional_owners) { 'yes' }
        let(:additional_owners) { 'Jon Smith' }

        it 'shows number of employees details' do
          within(business_card) do |card|
            expect(card).to have_summary_row 'Name of others in business', 'Jon Smith'
          end
        end
      end

      context 'when additional financial information is provided' do
        let(:salary) { { 'amount' => 12_100, 'frequency' => 'annual' } }
        let(:total_income_share_sales) { { 'amount' => 12_100, 'frequency' => 'annual' } }
        let(:percentage_profit_share) { 70.6 }

        it 'shows number of employees details' do
          within(business_card) do |card|
            expect(card).to have_summary_row 'Salary or remuneration', '£121.00 every year'
            expect(card).to have_summary_row 'Income from share sales', '£121.00 every year'
            expect(card).to have_summary_row 'Share of profits', '70.60%'
          end
        end
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers, RSpec/MultipleExpectations

  context 'when client does not have any businesses' do
    let(:application_data) do
      super().deep_merge('means_details' => { 'income_details' => { 'businesses' => [] } })
    end

    it 'does not display any businesses' do
      expect(page).to have_no_css('h2.govuk-summary-card__title', text: 'Self-employed business')
    end
  end
end

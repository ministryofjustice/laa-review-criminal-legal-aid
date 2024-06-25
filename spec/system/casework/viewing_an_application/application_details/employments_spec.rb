require 'rails_helper'

RSpec.describe 'Viewing the employments of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'when client/partner has employments' do
    let(:means_details) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'means').read) }

    let(:application_data) do
      super().deep_merge('means_details' => means_details)
    end

    it 'shows the employments section' do
      expect(page).to have_css('h2.govuk-heading-l', text: 'Jobs')
    end

    it 'shows the jobs with correct title' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'Job')
    end

    # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength, RSpec/NestedGroups
    describe 'a jobs card' do
      context 'with deductions' do
        context 'with job_card 1' do
          subject(:applicant_job_card) do
            page.all('h2.govuk-summary-card__title', text: 'Job 1')[0].ancestor('div.govuk-summary-card')
          end

          it 'shows jobs details with deductions' do
            within(applicant_job_card) do |card|
              expect(card).to have_summary_row "Employer's name", 'Joe Goodwin'
              expect(card).to have_summary_row 'Address',
                                               'address_line_one_y address_line_two_y city_y postcode_y country_y'
              expect(card).to have_summary_row 'Job title', 'Supervisor'
              expect(card).to have_summary_row 'Salary or wage', '£250.00 every year before tax'
              expect(card).to have_summary_row 'Income Tax', '£10.00 every week'
              expect(card).to have_summary_row 'National Insurance', '£20.00 every 2 weeks'
              expect(card).to have_summary_row 'Other deductions total', '£30.00 every year'
            end
          end
        end

        context 'with job_card 2' do
          subject(:partner_job_card) do
            page.all('h2.govuk-summary-card__title', text: 'Job 1')[1].ancestor('div.govuk-summary-card')
          end

          it 'shows jobs details with deductions' do
            within(partner_job_card) do |card|
              expect(card).to have_summary_row "Employer's name", 'Andy Murray'
              expect(card).to have_summary_row 'Address',
                                               'address_line_one_a address_line_two_a city_a postcode_a country_a'
              expect(card).to have_summary_row 'Job title', 'Manager'
              expect(card).to have_summary_row 'Salary or wage', '£150.00 every year before tax'
              expect(card).to have_summary_row 'Income Tax', '£20.00 every week'
              expect(card).to have_summary_row 'National Insurance', '£30.00 every 2 weeks'
              expect(card).to have_summary_row 'Other deductions total', '£40.00 every year'
            end
          end
        end
      end

      context 'without deductions' do
        context 'with job_card 1' do
          subject(:applicant_job_card) do
            page.all('h2.govuk-summary-card__title', text: 'Job 2')[0].ancestor('div.govuk-summary-card')
          end

          it 'shows jobs details without deductions' do
            within(applicant_job_card) do |card|
              expect(card).to have_summary_row "Employer's name", 'Teegan Ayala'
              expect(card).to have_summary_row 'Address',
                                               'address_line_one_x address_line_two_x city_x postcode_x country_x'
              expect(card).to have_summary_row 'Job title', 'Manager'
              expect(card).to have_summary_row 'Salary or wage', '£350.00 every year after tax'
              expect(card).to have_summary_row 'Deductions', 'None'
            end
          end
        end

        context 'with job_card 2' do
          subject(:partner_job_card) do
            page.all('h2.govuk-summary-card__title', text: 'Job 2')[1].ancestor('div.govuk-summary-card')
          end

          it 'shows jobs details without deductions' do
            within(partner_job_card) do |card|
              expect(card).to have_summary_row "Employer's name", 'Joe Goodwin'
              expect(card).to have_summary_row 'Address',
                                               'address_line_one_z address_line_two_z city_z postcode_z country_z'
              expect(card).to have_summary_row 'Job title', 'Manager'
              expect(card).to have_summary_row 'Salary or wage', '£250.00 every year after tax'
              expect(card).to have_summary_row 'Deductions', 'None'
            end
          end
        end
      end
    end
    # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength, RSpec/NestedGroups
  end
end

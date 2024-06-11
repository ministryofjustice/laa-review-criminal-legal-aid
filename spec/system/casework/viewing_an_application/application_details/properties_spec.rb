require 'rails_helper'

RSpec.describe 'Viewing the properties of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'when client has properties' do
    let(:means_details) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'means').read) }

    let(:application_data) do
      super().deep_merge('means_details' => means_details)
    end

    it 'shows the properties section' do
      expect(page).to have_css('h2.govuk-heading-l', text: 'Assets')
    end

    it 'shows the properties with correct title' do
      expect(page).to have_css('h2.govuk-summary-card__title', text: 'Residential property')
    end

    describe 'a properties card' do
      subject(:property_card) do
        page.find('h2.govuk-summary-card__title', text: 'Residential property').ancestor('div.govuk-summary-card')
      end

      it 'shows properties details' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
        within(property_card) do |card|
          expect(card).to have_summary_row 'Type of property', 'other house type'
          expect(card).to have_summary_row 'Number of bedrooms', '2'
          expect(card).to have_summary_row 'Value of property', '£200,000.00'
          expect(card).to have_summary_row 'Amount left to pay on the mortgage', '£100,000.00'
          expect(card).to have_summary_row 'Percentage of the property owned by client', '80.00%'
          expect(card).to have_summary_row "Percentage of the property owned by client's partner", '20.00%'
          expect(card).to have_summary_row 'Is the address of the property the same as client’s home address?', 'Yes'
          expect(card).to have_summary_row 'Address',
                                           'address_line_one_x address_line_two_x city_x postcode_x country_x'
          expect(card).to have_summary_row 'Does anyone else own part of the property?', 'No'
          expect(card).to have_summary_row 'Name of 1 other owner', 'Jack'
          expect(card).to have_summary_row 'Relationship to client', 'Ex-partner'
          expect(card).to have_summary_row 'Percentage of the property they own', '20.00%'
        end
      end
    end
  end

  context 'when client does not have properties' do
    let(:application_data) do
      super().deep_merge('case_details' => { 'case_type' => 'either_way' },
                         'means_details' => { 'capital_details' => { 'properties' => [],
'has_no_properties' => 'yes' } })
    end

    describe 'an no assets card' do
      subject(:property_card) do
        page.find('h2.govuk-summary-card__title', text: 'Assets').ancestor('div.govuk-summary-card')
      end

      it 'shows absent answer assets details' do
        within(property_card) do |card|
          expect(card).to have_summary_row 'Which assets does the client own or part-own inside or outside the UK?',
                                           'None'
        end
      end
    end
  end
end

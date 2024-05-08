require 'rails_helper'

RSpec.describe 'Viewing the co-defendants listed in an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  describe 'displaying a co-defendant with conflict' do
    subject(:codefendant_card) do
      page.find('h2.govuk-summary-card__title', text: 'Co-defendant')
          .ancestor('div.govuk-summary-card')
    end

    it 'shows co-defendant details' do # rubocop:disable RSpec/MultipleExpectations
      within(codefendant_card) do |card|
        expect(card).to have_summary_row 'First name', 'Zoe'
        expect(card).to have_summary_row 'Last name', 'Blogs'
        expect(card).to have_summary_row 'Conflict of interest?', 'Yes'
      end
    end
  end

  describe 'displaying a co-defendant without conflict' do
    subject(:codefendant_card) do
      page.find('h2.govuk-summary-card__title', text: 'Co-defendant')
          .ancestor('div.govuk-summary-card')
    end

    let(:application_data) do
      super().deep_merge(
        { case_details: { codefendants: [
          { first_name: 'Joe', last_name: 'Bates', conflict_of_interest: 'no' }
        ] } }.deep_stringify_keys
      )
    end

    it 'shows co-defendant details' do
      within(codefendant_card) do |card|
        expect(card).to have_summary_row 'Conflict of interest?', 'No conflict'
      end
    end
  end

  describe 'when no co-defendants' do
    subject(:codefendant_card) do
      page.find('h2.govuk-summary-card__title', text: 'Co-defendants')
          .ancestor('div.govuk-summary-card')
    end

    let(:application_data) do
      super().deep_merge('case_details' => { 'codefendants' => [] })
    end

    it 'shows that there are none' do
      within(codefendant_card) do |card|
        expect(card).to have_summary_row 'Co-defendants?', 'None'
      end
    end
  end
end

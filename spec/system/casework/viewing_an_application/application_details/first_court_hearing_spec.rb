require 'rails_helper'

RSpec.describe 'When viewing first court hearing details' do
  include_context 'with stubbed application'
  let(:card) do
    page.find('h2.govuk-summary-card__title', text: 'First court hearing').ancestor('div.govuk-summary-card')
  end

  before do
    visit crime_application_path(application_id)
  end

  it 'shows the first court hearing details' do
    within(card) do |card|
      expect(card).to have_summary_row(
        'What court is the hearing at', 'Bristol Magistrates Court'
      )
    end
  end

  context 'when next court hearing is missing' do
    let(:application_data) do
      super().deep_merge('case_details' => { 'hearing_date' => nil })
    end

    it 'shows the first court hearing details' do
      within(card) do |card|
        expect(card).to have_summary_row(
          'What court is the hearing at', 'Bristol Magistrates Court'
        )
      end
    end
  end
end

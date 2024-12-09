require 'rails_helper'

RSpec.describe 'When viewing next court hearing details' do
  include_context 'with stubbed application'
  let(:card) do
    page.find('h2.govuk-summary-card__title', text: 'Next court hearing').ancestor('div.govuk-summary-card')
  end

  before do
    visit crime_application_path(application_id)
  end

  it 'shows the next court hearing details' do # rubocop:disable RSpec/MultipleExpectations
    within(card) do |card|
      expect(card).to have_summary_row(
        'What court is the hearing at', "Cardiff Magistrates' Court"
      )
      expect(card).to have_summary_row 'When is the next hearing?', '11/11/2024'
      expect(card).to have_summary_row 'Same court as first hearing?', 'No'
    end
  end
end

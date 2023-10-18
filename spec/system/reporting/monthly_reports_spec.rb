require 'rails_helper'

RSpec.describe 'Monthly Reports' do
  include_context 'when viewing a temporal report'

  let(:interval) { Types::TemporalInterval['monthly'] }
  let(:period) { '2023-January' }

  it 'shows the monthly report\'s title' do
    heading_text = page.first('h1').text
    expect(heading_text).to eq('Caseworker report')
  end

  it 'warns that data is experimental' do
    warning_text = 'This report is experimental and under active development. It may contain inaccurate information.'

    within('div.govuk-warning-text') do
      expect(page).to have_content(warning_text)
    end
  end

  it 'shows the caseworker report table for the given month' do
    expect(page).to have_text('Fred Smitheg')
  end

  context 'when on the latest complete month' do
    let(:period) { '2022-December' }

    it 'includes a link to the next month\'s report' do
      expect { click_link 'Next' }.to change { page.first('h2').text }.from(
        'December, 2022'
      ).to(
        'January, 2023'
      )
    end
  end

  context 'when on the current month' do
    it 'does not show the next report link' do
      expect(page).not_to have_content 'Next'
    end
  end

  it 'includes a link to the previous month\'s report' do
    expect { click_link 'Previous' }.to change { page.first('h2').text }.from(
      'January, 2023'
    ).to(
      'December, 2022'
    )
  end

  context 'when period is not of correct format' do
    let(:period) { '2023-01' }

    it 'show page not found' do
      expect(page).to have_http_status(:not_found)
    end
  end
end

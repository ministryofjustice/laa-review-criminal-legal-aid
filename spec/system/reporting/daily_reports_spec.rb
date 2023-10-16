require 'rails_helper'

RSpec.describe 'Daily reports' do
  include_context 'when viewing a temporal report'

  let(:interval) { Types::TemporalInterval['daily'] }
  let(:period) { '2023-01-01' }

  it 'shows the daily report\'s title' do
    heading_text = page.first('h1').text
    expect(heading_text).to eq('Caseworker report')
  end

  it 'shows the daily report\'s period name' do
    heading_text = page.first('h2').text
    expect(heading_text).to eq('Sunday 1 January 2023')
  end

  it 'shows the caseworker report table for the given day' do
    expect(page).to have_text('Fred Smitheg')
  end

  it 'includes a link to the next days\'s report' do
    expect { click_link 'Next' }.to change { page.first('h2').text }.from(
      'Sunday 1 January 2023'
    ).to(
      'Monday 2 January 2023'
    )
  end

  context 'when on the current day' do
    let(:period) { '2023-01-02' }

    it 'does not show the next report link' do
      expect(page).not_to have_content 'Next'
    end
  end

  it 'includes a link to the previous days\'s report' do
    expect { click_link 'Previous' }.to change { page.first('h2').text }.from(
      'Sunday 1 January 2023'
    ).to(
      'Saturday 31 December 2022'
    )
  end

  context 'when period is not of correct format' do
    let(:period) { '2023-August' }

    it 'show page not found' do
      expect(page).to have_http_status(:not_found)
    end
  end
end

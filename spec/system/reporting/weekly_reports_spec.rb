require 'rails_helper'

RSpec.describe 'Weekly Reports' do
  include_context 'when viewing a temporal report'

  let(:interval) { Types::TemporalInterval['weekly'] }
  let(:period) { '2022-52' }

  it 'shows the weekly report\'s title' do
    heading_text = page.first('h1').text
    expect(heading_text).to eq('Caseworker report')
  end

  it 'shows the reports date range' do
    expect(page.first('h3')).to have_text('Monday 26 December to Sunday 1 January 2023')
  end

  it 'shows the caseworker report table for the given week' do
    expect(page).to have_text('Fred Smitheg')
  end

  it 'includes a link to the next week\'s report' do
    expect { click_link 'Next' }.to change { page.first('h2').text }.from(
      'Week 52, 2022'
    ).to(
      'Week 1, 2023'
    )
  end

  it 'includes a link to the previous week\'s report' do
    expect { click_link 'Previous' }.to change { page.first('h2').text }.from(
      'Week 52, 2022'
    ).to(
      'Week 51, 2022'
    )
  end

  context 'when period is not of correct format' do
    let(:period) { '2023-54' }

    it 'show page not found' do
      expect(page).to have_http_status(:not_found)
    end
  end
end

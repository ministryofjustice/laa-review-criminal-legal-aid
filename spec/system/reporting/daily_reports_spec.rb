require 'rails_helper'

RSpec.describe 'Daily reports' do
  include_context 'when viewing a temporal report'

  let(:interval) { Types::TemporalInterval['day'] }
  let(:period) { '2023-01-01' }

  it 'shows the daily report\'s title' do
    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Caseworker daily: Sunday 1 January 2023')
  end

  it 'shows the reports date range' do
    subheading_text = page.first('h2').text
    expect(subheading_text).to eq('00:00—23:59')
  end

  it 'shows the caseworker report table for the given day' do
    expect(page).to have_text('Fred Smitheg')
  end

  it 'includes a link to the next days\'s report' do
    expect { click_link 'Next' }.to change { page.first('h1').text }.from(
      'Caseworker daily: Sunday 1 January 2023'
    ).to(
      'Caseworker daily: Monday 2 January 2023'
    )
  end

  context 'when on the current day' do
    let(:period) { '2023-01-02' }

    it 'does not show the next report link' do
      expect(page).not_to have_content 'Next'
    end
  end

  it 'includes a link to the previous days\'s report' do
    expect { click_link 'Previous' }.to change { page.first('h1').text }.from(
      'Caseworker daily: Sunday 1 January 2023'
    ).to(
      'Caseworker daily: Saturday 31 December 2022'
    )
  end
end

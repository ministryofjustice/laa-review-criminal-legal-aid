require 'rails_helper'

RSpec.describe 'Primary navigation' do
  include_context 'with stubbed search'

  before do
    visit '/'
  end

  context 'with the "Your list" link' do
    describe 'before assignment' do
      it 'has the correct number of applications in the link' do
        expect(page).to have_content('Your list (0)')
      end
    end

    describe 'after assignment' do
      before do
        click_on 'Open applications'
        click_on('Kit Pound')
        click_on('Assign to your list')
        click_on 'Open applications'
      end

      it 'has the correct number of applications in the link' do
        expect(page).to have_content('Your list (1)')
      end

      it 'takes the user to their list when clicked' do
        click_on('Your list (1)')

        heading_text = page.first('.govuk-heading-xl').text

        expect(heading_text).to eq('Your list')
      end
    end
  end

  context 'with the other primary nav links' do
    it 'takes you to search when you click "Search"' do
      click_on('Search')

      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Search for an application')
    end
  end

  it 'takes you to all applications when you click "Open applications"' do
    click_on('Open applications')

    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Open applications')
    expect(page).to have_current_path '/applications/open'
  end

  it 'takes you to closed applications when you click "Closed applications"' do
    click_on('Closed applications')

    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Closed applications')
    expect(page).to have_current_path '/applications/closed'
  end
end

require 'rails_helper'

RSpec.describe 'Applications Dashboard' do
  before do
    visit '/applications'
  end

  context 'with the "Your list" link' do
    describe 'before assignment' do
      it 'has the correct number of applications in the link' do
        expect(page).to have_content('Your list (0)')
      end
    end

    describe 'after assignment' do
      before do
        click_on('Kit Pound')
        click_on('Assign to myself')
        visit '/applications'
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
    it 'takes you to All applications when you click "All open applications"' do
      click_on('All open applications')

      heading_text = page.first('.govuk-heading-xl').text
      first_row_text = page.first('.app-dashboard-table tbody tr').text

      expect(heading_text).to eq('All open applications')
      expect(first_row_text).to eq('Kit Pound LAA-696dd4 27 Oct 2022')
    end
  end
end

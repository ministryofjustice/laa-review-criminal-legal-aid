require 'rails_helper'

RSpec.describe 'Viewing an application that has been deleted' do
  include_context 'with a deleted application'

  before do
    visit crime_application_path(application_id)
  end

  it 'replaces the review status with "Personal data deleted"' do
    within('.govuk-tag--grey') do
      expect(page).to have_text('Personal data deleted')
    end
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('casework.crime_applications.show.page_title')
  end

  describe 'applications details' do
    it 'shows relevant details' do # rubocop:disable RSpec/MultipleExpectations
      within(summary_card('Overview')) do |card|
        expect(card).to have_summary_row 'Application type', 'Initial application'
        expect(card).to have_summary_row 'Date stamp', '24/10/2022'
        expect(card).to have_summary_row 'Date submitted', '24/10/2022'
        expect(card).to have_summary_row 'Office account number', '1A123B'
      end
    end
  end

  describe 'applications history' do
    before do
      click_link 'Application history'
    end

    it 'shows the deletion event at the top of the application history' do
      expect(page.first('.app-dashboard-table tbody tr').text).to match(
        'System Personal data deleted in accordance with data retention policy'
      )
    end
  end
end

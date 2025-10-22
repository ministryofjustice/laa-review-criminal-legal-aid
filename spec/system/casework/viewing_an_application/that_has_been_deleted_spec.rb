require 'rails_helper'

RSpec.describe 'Viewing an application that has been deleted' do
  include_context 'with a deleted application'

  before do
    visit crime_application_path(application_id)
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

  it 'includes the page title' do
    expect(page).to have_content I18n.t('casework.crime_applications.show.page_title')
  end
end

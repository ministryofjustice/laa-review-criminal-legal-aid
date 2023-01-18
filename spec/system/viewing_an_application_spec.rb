require 'rails_helper'

RSpec.describe 'Viewing an application' do
  include_context 'with stubbed search'

  context 'when an application exists in the datastore' do
    context 'when an application is open' do
      before do
        visit '/'
        click_on 'All open applications'
        click_on('Kit Pound')
      end

      it 'includes the page title' do
        expect(page).to have_content I18n.t('crime_applications.show.page_title')
      end

      it 'includes the users details' do
        expect(page).to have_content('AJ123456C')
      end
    end

    context 'when an application is closed' do
      let(:stubbed_search_results) do
        [
          ApplicationSearchResult.new(
            applicant_name: 'Ella Fitzgerald',
            resource_id: '5aa4c689-6fb5-47ff-9567-5efe7f8ac211',
            reference: 5_230_234_344,
            status: 'returned',
            submitted_at: '2022-12-14T16:58:15.000+00:00',
            returned_at: '2022-12-14T16:58:15.000+00:00'
          )
        ]
      end

      before do
        visit '/'
        click_on 'Closed applications'
        click_on('Ella Fitzgerald')
      end

      it 'includes the page title' do
        expect(page).to have_content I18n.t('crime_applications.show.page_title')
      end

      it 'includes the users details' do
        expect(page).to have_content('JC123458B')
      end
    end
  end

  context 'when an application does not exist in the datastore' do
    before do
      visit '/'
      visit '/applications/123'
    end

    it 'includes the page title' do
      expect(page).to have_content('Page not found')
    end
  end
end

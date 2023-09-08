require 'rails_helper'

RSpec.describe 'Paginated search results' do
  include_context 'when search results are returned'

  let(:current_page) { 1 }

  let(:datastore_response) do
    pagination = Pagination.new(
      current_page: current_page,
      total_count: 101,
      total_pages: 3,
      limit_value: 50
    ).to_h

    records = stubbed_search_results.map(&:to_h)

    { pagination:, records: }.deep_stringify_keys
  end

  before do
    visit '/'
    click_link 'Search'
    click_button 'Search'
  end

  context 'when on the first page' do
    it 'shows a link for each page and next' do
      within('nav.govuk-pagination') do
        %w[1 2 3 Next].each do |link_text|
          expect(page).to have_link(link_text)
        end
      end
    end
  end

  context 'when on the last page' do
    let(:current_page) { 3 }

    it 'shows a link to the previous page' do
      within('nav.govuk-pagination') do
        expect(page).not_to have_link('Next')
        expect(page).to have_link('Previous')
      end
    end
  end

  context 'when page links are truncated' do
    let(:datastore_response) do
      pagination = Pagination.new(
        current_page: 4,
        total_count: 101,
        total_pages: 51,
        limit_value: 2
      ).to_h

      records = stubbed_search_results.map(&:to_h)

      { pagination:, records: }.deep_stringify_keys
    end

    it 'shows truncated page links' do
      within('nav.govuk-pagination') do
        expect(page).to have_content("Previous\n1 2 3 4 5 6 7 8 &ctdot;\nNext")
      end
    end
  end

  describe 'clicking Next' do
    before do
      within('nav.govuk-pagination') { click_link('Next') }
    end

    it 'shows the next page' do
      query = Addressable::URI.parse(page.current_url).query
      expect(query).to match('page=2')
    end
  end
end

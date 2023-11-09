require 'rails_helper'

RSpec.shared_examples 'a paginated page' do |options|
  include_context 'with many other users'

  let(:path) { options.fetch(:path) }

  before do
    make_users(100)
    visit path
  end

  it 'shows the correct page number' do
    current_page = first('.govuk-pagination__item--current').text

    expect(current_page).to have_text('2')
  end

  it 'shows 50 entries per page' do
    expect(page).to have_css('.govuk-table__body > .govuk-table__row', count: 50)
  end
end

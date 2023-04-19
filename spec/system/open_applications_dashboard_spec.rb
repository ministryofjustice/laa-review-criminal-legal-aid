require 'rails_helper'

RSpec.describe 'Open Applications Dashboard' do
  include_context 'with stubbed search'

  before do
    visit '/'
    click_on 'All open applications'
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('crime_applications.index.open_title')
  end

  it 'includes the correct headings' do
    column_headings = page.first('.app-dashboard-table thead tr').text.squish

    # rubocop:disable Layout/LineLength
    expect(column_headings).to eq("Applicant's name Reference number Date received Business days since application was received Caseworker")
    # rubocop:enable Layout/LineLength
  end

  it 'shows the correct information' do
    first_row_text = page.first('.app-dashboard-table tbody tr').text

    days_ago = Calendar.new.business_days_between(
      DateTime.parse('2022-10-27T14:09:11.000+00:00'),
      Time.zone.now.to_date
    )

    expect(first_row_text).to eq("Kit Pound 120398120 27 Oct 2022 #{days_ago} days")
  end

  it 'has the correct count' do
    expect(page).to have_content('2 applications')
  end

  it 'can be used to navigate to an application' do
    click_on('Kit Pound')

    expect(current_url).to match(
      'applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a'
    )
  end

  describe 'sortable table headers' do
    subject(:column_sort) do
      page.find('thead tr th#submitted_at')['aria-sort']
    end

    it 'is active and ascending by default' do
      expect(column_sort).to eq 'ascending'
    end

    context 'when clicked' do
      it 'changes to adescending when it is selected' do
        expect { click_button 'Date received' }.not_to(change { current_path })
        expect(column_sort).to eq 'descending'
      end
    end
  end
end

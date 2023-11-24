require 'rails_helper'

RSpec.describe 'Open Applications Dashboard' do
  include_context 'with stubbed search'

  before do
    allow(FeatureFlags).to receive(:work_stream) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: false)
    }
    visit '/'
    click_on 'All open applications'
  end

  it 'shows only open applications' do
    expect_datastore_to_have_been_searched_with(
      { review_status: Types::REVIEW_STATUS_GROUPS['open'],
        work_stream: %w[extradition national_crime_team criminal_applications_team] },
      sorting: ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
    )
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('casework.crime_applications.index.open_title')
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
      Date.parse('2022-10-27'), Time.current.in_time_zone('London')
    )

    expect(first_row_text).to eq("Kit Pound 120398120 27 Oct 2022 #{days_ago} days")
  end

  it 'receives the application if not already received' do
    returned_application = CrimeApplication.find(
      stubbed_search_results.first.resource_id
    )

    expect(returned_application.review_status).to be(:open)
  end

  it 'has the correct count' do
    expect(page).to have_content('There are 2 open applications that need to be reviewed.')
  end

  it 'can be used to navigate to an application' do
    click_on('Kit Pound')

    expect(current_url).to match(
      'applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a'
    )
  end

  it_behaves_like 'a table with sortable headers' do
    let(:active_sort_headers) { ['Date received', 'Business days since application was received'] }
    let(:active_sort_direction) { 'ascending' }
    let(:inactive_sort_headers) { ['Applicant\'s name'] }
  end

  context 'when work stream feature flag in is enabled' do
    before do
      allow(FeatureFlags).to receive(:work_stream) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }
      click_on 'All open applications'
    end

    it 'shows only extradition open applications' do
      expect_datastore_to_have_been_searched_with(
        { review_status: Types::REVIEW_STATUS_GROUPS['open'],
          work_stream: %w[extradition] },
        sorting: ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
      )
    end

    it 'includes tabs for work streams' do
      tabs = find(:xpath, "//div[@class='govuk-tabs']")

      expect(tabs).to have_content 'Extradition National crime team Criminal applications team'
    end

    context 'when viewing closed applications by work stream' do
      it 'searches for extradition closed applications' do
        click_on 'Extradition'
        expect_datastore_to_have_been_searched_with(
          { review_status: Types::REVIEW_STATUS_GROUPS['open'],
            work_stream: %w[extradition] },
          sorting: ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending'),
          number_of_times: 2
        )
      end

      it 'searches for national crime team closed applications' do
        click_on 'National crime team'
        expect_datastore_to_have_been_searched_with(
          { review_status: Types::REVIEW_STATUS_GROUPS['open'],
            work_stream: %w[national_crime_team] },
          sorting: ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
        )
      end

      it 'searches for criminal applications team closed applications' do
        click_on 'Criminal applications team'
        expect_datastore_to_have_been_searched_with(
          { review_status: Types::REVIEW_STATUS_GROUPS['open'],
            work_stream: %w[criminal_applications_team] },
          sorting: ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
        )
      end
    end
  end
end

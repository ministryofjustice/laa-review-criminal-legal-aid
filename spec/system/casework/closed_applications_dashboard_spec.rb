require 'rails_helper'

RSpec.describe 'Closed Applications Dashboard' do
  include_context 'with stubbed search'

  let(:application_id) { '47a93336-7da6-48ac-b139-808ddd555a41' }

  let(:stubbed_search_results) do
    [
      ApplicationSearchResult.new(
        applicant_name: 'John Potter',
        resource_id: '47a93336-7da6-48ac-b139-808ddd555a41',
        reference: 6_000_002,
        status: 'returned',
        work_stream: 'criminal_applications_team',
        submitted_at: '2022-09-27T14:10:00.000+00:00',
        reviewed_at: '2022-12-15T16:58:15.000+00:00'
      )
    ]
  end

  let(:work_stream_flag_enabled) { true }

  let(:user_id) { current_user_id }

  before do
    visit '/'
    click_on 'open applications'

    allow(FeatureFlags).to receive(:work_stream) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: work_stream_flag_enabled)
    }

    return_details = ReturnDetails.new(
      reason: ReturnDetails::RETURN_REASONS.first,
      details: 'Detailed reason'
    ).attributes

    Reviewing::SendBack.new(
      application_id:,
      user_id:,
      return_details:
    ).call

    click_on 'Closed applications'
  end

  context 'when work stream feature flag disabled' do
    let(:work_stream_flag_enabled) { false }

    it 'shows only closed applications' do
      expect_datastore_to_have_been_searched_with(
        { review_status: Types::REVIEW_STATUS_GROUPS['closed'],
            work_stream: %w[criminal_applications_team criminal_applications_team_2 extradition] },
        sorting: ApplicationSearchSorting.new(sort_by: 'reviewed_at', sort_direction: 'descending')
      )
    end
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('casework.crime_applications.index.closed_title')
  end

  it 'has the correct body' do
    expect(page).to have_content('These applications have been completed or sent back to the provider.')
  end

  it 'shows the correct information' do
    first_row_text = page.first('.app-dashboard-table tbody tr').text
    reviewed_at = I18n.l(Time.current.in_time_zone('London'))
    expect(first_row_text).to eq("John Potter 6000002 27 Sep 2022 #{reviewed_at} Joe EXAMPLE Sent back to provider")
  end

  it 'can be used to navigate to an application' do
    click_on('John Potter')

    expect(current_url).to match(
      'applications/47a93336-7da6-48ac-b139-808ddd555a41'
    )
  end

  it 'includes the correct headings' do # rubocop:disable RSpec/ExampleLength
    column_headings = page.all('.app-dashboard-table thead tr th.govuk-table__header').map(&:text)

    expected_headings = [
      "Applicant's name",
      'Reference number',
      'Date received',
      'Date closed',
      'Closed by',
      'Status'
    ]

    expect(column_headings).to eq expected_headings
  end

  it_behaves_like 'a table with sortable headers' do
    let(:active_sort_headers) { ['Date closed'] }
    let(:active_sort_direction) { 'descending' }
    let(:inactive_sort_headers) { ['Applicant\'s name', 'Date received'] }
  end

  context 'when work stream feature flag is enabled' do
    let(:work_stream_flag_enabled) { true }

    it 'includes tabs for work streams' do
      tabs = find(:xpath, "//div[@class='govuk-tabs']")

      expect(tabs).to have_content 'CAT 1 CAT 2 Extradition'
    end

    context 'when viewing closed applications by work stream' do
      it 'searches for extradition closed applications' do
        click_on 'Extradition'
        expect_datastore_to_have_been_searched_with(
          { review_status: Types::REVIEW_STATUS_GROUPS['closed'], work_stream: %w[extradition] },
          sorting: ApplicationSearchSorting.new(sort_by: 'reviewed_at', sort_direction: 'descending')
        )
      end

      it 'searches for CAT 2 closed applications' do
        click_on 'CAT 2'
        expect_datastore_to_have_been_searched_with(
          { review_status: Types::REVIEW_STATUS_GROUPS['closed'], work_stream: %w[criminal_applications_team_2] },
          sorting: ApplicationSearchSorting.new(sort_by: 'reviewed_at', sort_direction: 'descending')
        )
      end

      it 'searches for CAT 1 closed applications' do
        click_on 'CAT 1'
        expect_datastore_to_have_been_searched_with(
          { review_status: Types::REVIEW_STATUS_GROUPS['closed'],
            work_stream: %w[criminal_applications_team] },
          sorting: ApplicationSearchSorting.new(sort_by: 'reviewed_at', sort_direction: 'descending'),
          number_of_times: 2
        )
      end
    end
  end
end

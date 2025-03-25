require 'rails_helper'

RSpec.describe 'Closed Applications' do
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
        reviewed_at: '2022-12-15T16:58:15.000+00:00',
        parent_id: parent_id,
        case_type: 'summary_only',
        application_type: 'initial'
      )
    ]
  end

  let(:user_id) { current_user_id }
  let(:parent_id) { nil }
  let(:application_type) { 'initial' }

  before do
    visit '/'
    click_on 'open applications'

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

  it 'includes the page title' do
    expect(page).to have_content I18n.t('casework.crime_applications.index.closed_title')
  end

  it 'has the correct body' do
    expect(page).to have_content('These applications have been completed or sent back to the provider.')
  end

  it 'shows the correct information' do
    first_row_text = page.first('.app-table tbody tr').text
    reviewed_at = I18n.l(Time.current.in_time_zone('London'))
    expected_text = "John Potter 6000002 Initial 27 Sep 2022 #{reviewed_at} Joe EXAMPLE Sent back to provider"
    expect(first_row_text).to eq(expected_text)
  end

  it 'can be used to navigate to an application' do
    click_on('John Potter')

    expect(current_url).to match(
      'applications/47a93336-7da6-48ac-b139-808ddd555a41'
    )
  end

  it 'includes the correct headings' do # rubocop:disable RSpec/ExampleLength
    column_headings = page.all('.app-table thead tr th.govuk-table__header').map(&:text)

    expected_headings = [
      "Applicant's name",
      'LAA reference',
      'Application type',
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
    let(:inactive_sort_headers) { ['Applicant\'s name', 'Date received', 'Application type'] }
  end

  context 'when work stream feature flag is enabled' do
    it 'includes tabs for work streams' do
      tabs = find(:xpath, "//div[@class='govuk-tabs']")

      expect(tabs).to have_content 'CAT 1 CAT 2 Extradition'
    end

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

  context 'when viewing a resubmitted application' do
    let(:parent_id) { SecureRandom.uuid }

    before do
      click_on 'Closed applications'
      click_on('John Potter')
    end

    context 'when viewing an application of type `initial`' do
      it 'navigates to the application history page' do
        expect(current_url).to match('applications/47a93336-7da6-48ac-b139-808ddd555a41/history')
      end
    end

    context 'when viewing an application of type `post submission evidence`' do
      let(:application_type) { 'post_submission_evidence' }

      it 'navigates to the application details page' do
        expect(current_url).to match('applications/47a93336-7da6-48ac-b139-808ddd555a41')
      end
    end
  end
end

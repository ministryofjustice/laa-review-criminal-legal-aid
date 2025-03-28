require 'rails_helper'

RSpec.describe 'Open Applications' do
  include_context 'with stubbed search'
  let(:report_turbo_link_work_stream_params) do
    report_link = URI(page.find('turbo-frame#current_workload_report', visible: false)['src'])
    CGI.parse(report_link.query)['work_streams[]']
  end

  before do
    visit '/'
    click_on 'Open applications'
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('casework.crime_applications.index.open_title')
  end

  it 'includes the correct headings' do
    column_headings = page.all('.app-table thead tr th.govuk-table__header').map(&:text)

    expect(column_headings).to eq(["Applicant's name", 'LAA reference', 'Application type', 'Date received',
                                   'Business days since received', 'Caseworker'])
  end

  it 'shows the correct information' do
    first_row_text = page.first('.app-table tbody tr').text

    days_ago = Calendar.new.business_days_between(
      Date.parse('2022-10-27'), Time.current.in_time_zone('London')
    )

    expect(first_row_text).to eq(
      "Kit Pound 120398120 Initial 27 Oct 2022 #{days_ago} days No data exists for Caseworker"
    )
  end

  it 'receives the application if not already received' do
    returned_application = CrimeApplication.find(
      stubbed_search_results.first.resource_id
    )

    expect(returned_application.review_status).to be(:open)
  end

  it 'has the correct count' do
    expect(page).to have_content('There are 3 open applications that need to be reviewed.')
  end

  it 'can be used to navigate to an application' do
    click_on('Kit Pound')

    expect(current_url).to match(
      'applications/696dd4fd-b619-4637-ab42-a5f4565bcf4a'
    )
  end

  it_behaves_like 'a table with sortable headers' do
    let(:active_sort_headers) { ['Date received', 'Business days since received'] }
    let(:active_sort_direction) { 'ascending' }
    let(:inactive_sort_headers) { ['Applicant\'s name', 'Application type'] }
  end

  it 'includes tabs for work streams' do
    tabs = find(:xpath, "//div[@class='govuk-tabs']")

    expect(tabs).to have_content 'CAT 1 CAT 2 Extradition'
  end

  context 'when viewing open applications by work stream' do
    it 'searches for extradition open applications' do
      click_on 'Extradition'
      expect(page.find('.govuk-tabs__list-item--selected')).to have_content 'Extradition'
      expect_datastore_to_have_been_searched_with(
        { review_status: Types::REVIEW_STATUS_GROUPS['open'],
          work_stream: %w[extradition] },
        sorting: ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
      )
    end

    it 'shows the correct mini report' do
      click_on 'CAT 2'
      expect(report_turbo_link_work_stream_params).to eq ['cat_2']
    end

    it 'searches for CAT 2 open applications' do
      click_on 'CAT 2'
      expect(page.find('.govuk-tabs__list-item--selected')).to have_content 'CAT 2'
      expect_datastore_to_have_been_searched_with(
        { review_status: Types::REVIEW_STATUS_GROUPS['open'],
          work_stream: %w[criminal_applications_team_2] },
        sorting: ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
      )
    end

    it 'searches for CAT 1 open applications' do
      click_on 'CAT 1'
      expect(page.find('.govuk-tabs__list-item--selected')).to have_content 'CAT 1'
      expect_datastore_to_have_been_searched_with(
        { review_status: Types::REVIEW_STATUS_GROUPS['open'],
          work_stream: %w[criminal_applications_team] },
        sorting: ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending'),
        number_of_times: 2
      )
    end

    context 'with a caseworker that access to only one work stream' do
      let(:current_user_competencies) { ['criminal_applications_team_2'] }

      it 'includes tabs only for that work stream' do
        expect(page.all('.govuk-tabs__list-item').size).to be 1
        expect(page.find('.govuk-tabs__list-item--selected')).to have_content 'CAT 2'
      end

      it 'applications from all streams' do
        expect_datastore_to_have_been_searched_with(
          { review_status: Types::REVIEW_STATUS_GROUPS['open'],
            work_stream: %w[criminal_applications_team_2] },
          sorting: ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
        )
      end

      it 'shows not found when trying to view another stream' do
        visit open_crime_applications_path(work_stream: 'cat_1')
        expect(page).to have_http_status :not_found
      end

      it 'shows not found when trying to view a stream that does not exist' do
        visit open_crime_applications_path(work_stream: 'not_a_stream')
        expect(page).to have_http_status :not_found
      end
    end
  end

  context 'when viewing a resubmitted application' do
    before do
      click_on 'Open applications'
      click_on('Jessica Rhode')
    end

    context 'when viewing an application of type `initial`' do
      it 'navigates to the application history page' do
        expect(current_url).to match('applications/012a553f-e9b7-4e9a-a265-67682b572fd0/history')
      end
    end

    context 'when viewing an application of type `post submission evidence`' do
      let(:application_type) { 'post_submission_evidence' }

      it 'navigates to the application details page' do
        expect(current_url).to match('applications/012a553f-e9b7-4e9a-a265-67682b572fd0')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Weekly Reports' do
  include_context 'with an existing application'

  let(:current_user_role) { UserRole::DATA_ANALYST }

  before do
    travel_to(Time.zone.local(2023, 0o1, 0o1))

    user = User.create!(
      first_name: 'Fred',
      last_name: 'Smitheg',
      auth_oid: '976658f9-f3d5-49ec-b0a9-485ff8b308fa',
      email: 'Fred.Smitheg@justice.gov.uk'
    )

    Assigning::AssignToUser.new(
      user_id: user.id,
      to_whom_id: user.id,
      assignment_id: crime_application_id
    ).call

    report = Reporting::WeeklyReport.new(
      report_type: 'caseworker_report',
      date: Time.current.in_time_zone('London').to_date
    )

    visit reporting_weekly_report_path(
      report_type: report.report_type,
      epoch: report.to_param
    )
  end

  it 'shows the weekly report\'s title' do
    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Caseworker report: Week 52, 2022')
  end

  it 'shows the reports date range' do
    subheading_text = page.first('h2').text
    expect(subheading_text).to eq('Mon 26 Dec 22 — Sun 1 Jan 23')
  end

  it 'shows the caseworker report table for the given week' do
    expect(page).to have_text('Fred Smitheg')
  end

  it 'includes a link to the next weeks\'s report' do
    expect { click_link 'Next' }.to change { page.first('h1').text }.from(
      'Caseworker report: Week 52, 2022'
    ).to(
      'Caseworker report: Week 01, 2023'
    )
  end

  it 'includes a link to the previous weeks\'s report' do
    expect { click_link 'Previous' }.to change { page.first('h1').text }.from(
      'Caseworker report: Week 52, 2022'
    ).to(
      'Caseworker report: Week 51, 2022'
    )
  end
end

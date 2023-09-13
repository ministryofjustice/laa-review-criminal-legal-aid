require 'rails_helper'

RSpec.describe 'Monthly Reports' do
  include_context 'with an existing application'

  let(:current_user_role) { UserRole::DATA_ANALYST }

  before do
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

    report = Reporting::MonthlyReport.new(
      report_type: 'caseworker_report',
      date: Time.current.in_time_zone('London').to_date
    )

    visit reporting_monthly_report_path(
      report_type: report.report_type,
      month: report.to_param
    )
  end

  it 'shows the monthly report\'s title' do
    heading_text = page.first('.govuk-heading-xl').text
    expect(heading_text).to eq('Caseworker report, September 2023')
  end

  it 'warns that data is experimental' do
    warning_text = 'This report is experimental and under active development. It may contain inaccurate information.'

    within('div.govuk-warning-text') do
      expect(page).to have_content(warning_text)
    end
  end

  it 'shows the caseworker report table for the given month' do
    expect(page).to have_text('Fred Smitheg')
  end
end

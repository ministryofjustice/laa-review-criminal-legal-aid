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
        submitted_at: '2022-09-27T14:10:00.000+00:00',
        reviewed_at: '2022-12-15T16:58:15.000+00:00'
      )
    ]
  end

  let(:user_id) { User.find_by(auth_oid: current_user_auth_oid).id }

  before do
    visit '/'
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

  it 'shows only closed applications' do
    assert_api_searched_with_filter({ status: 'sent_back' })
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('crime_applications.index.closed_title')
  end

  it 'includes the correct headings' do
    column_headings = page.first('.app-dashboard-table thead tr').text.squish

    expect(column_headings).to eq('Applicant Ref. no. Date received Date reviewed Reviewed by Status')
  end

  it 'shows the correct information' do
    first_row_text = page.first('.app-dashboard-table tbody tr').text
    reviewed_at = I18n.l(Time.zone.now.to_date)
    expect(first_row_text).to eq("John Potter 6000002 27 Sep 2022 #{reviewed_at} Joe EXAMPLE Sent back to provider")
  end

  it 'has the correct count' do
    expect(page).to have_content('1 application')
  end

  it 'can be used to navigate to an application' do
    click_on('John Potter')

    expect(current_url).to match(
      'applications/47a93336-7da6-48ac-b139-808ddd555a41'
    )
  end

  describe 'sortable table headers' do
    subject(:column_sort) do
      page.find('thead tr th#reviewed_at')['aria-sort']
    end

    it 'is active and descending by default' do
      expect(column_sort).to eq 'descending'
    end

    context 'when clicked' do
      it 'changes to ascending when it is selected' do
        expect { click_button 'Date reviewed' }.not_to(change { current_path })
        expect(column_sort).to eq 'ascending'
      end
    end
  end
end

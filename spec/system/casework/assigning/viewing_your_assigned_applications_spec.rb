require 'rails_helper'

RSpec.describe 'Viewing your assigned application' do
  include_context 'with stubbed search'
  let(:assign_cta) { 'Assign to your list' }
  let(:application_id) { '1aa4c689-6fb5-47ff-9567-5eee7f8ac2cc' }
  let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }

  before do
    visit '/'
  end

  context 'when there are no assigned applications' do
    let(:stubbed_search_results) { [] }

    it 'includes the page title' do
      expect(page).to have_content I18n.t('casework.assigned_applications.index.page_title')
    end

    it 'shows shows how many assignments' do
      expect(page).to have_content 'No applications are assigned to you for review.'
    end
  end

  context 'when no application are assigned' do
    it 'shows how many assignments' do
      expect(page).to have_content 'No applications are assigned to you for review.'
      expect(page).to have_content 'Your list (0)'
    end
  end

  context 'when one application is assigned' do
    before do
      click_on 'All open applications'
      click_on('Kit Pound')
      click_on(assign_cta)
      visit '/'
    end

    it 'shows shows how many assignments' do
      expect(page).to have_content '1 application is assigned to you for review.'
    end
  end

  context 'when multiple applications are assigned' do
    let(:application_data) do
      super().deep_merge('id' => application_id.to_s,
                         'client_details' => { 'applicant' => { 'first_name' => 'Don', 'last_name' => 'JONES' } })
    end

    before do
      stub_request(
        :get,
        "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}"
      ).to_return(body: application_data.to_json, status: 200)

      click_on 'All open applications'
      click_on('Kit Pound')
      click_on(assign_cta)
      click_on 'All open applications'

      click_on('Don JONES')
      click_on(assign_cta)
      visit '/'
    end

    it 'shows shows how many assignments' do
      expect(page).to have_content '2 applications are assigned to you for review.'
    end

    it 'includes the correct headings' do
      column_headings = page.all('.app-dashboard-table thead tr th.govuk-table__header').map(&:text)

      expect(column_headings).to contain_exactly(
        "Applicant's name", 'Reference number', 'Workstream', 'Date received', 'Business days since application was received'
      )
    end

    it_behaves_like 'a table with sortable headers' do
      let(:active_sort_headers) { ['Date received', 'Business days since application was received'] }
      let(:active_sort_direction) { 'ascending' }
      let(:inactive_sort_headers) { ['Applicant\'s name'] }
    end
  end

  context 'when using the check all applications link' do
    before do
      click_on('Check all open applications')
    end

    it 'proceeds to the correct page' do
      expect(page).to have_content 'All open applications'
      expect(page).to have_current_path '/applications/open/extradition'
    end

    context 'when work stream feature flag in is not enabled' do
      before do
        allow(FeatureFlags).to receive(:work_stream) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
        visit '/'
      end

      it 'takes you to all open applications path when you click "All open applications"' do
        click_on('All open applications')
        expect(page).to have_current_path '/applications/open'
      end
    end
  end

  context 'when an assigned application is not found on the datastore' do
    let(:stubbed_search_results) { [] }

    # The wider process for handing this scenario has not been determined.
    # The solution tested here will result in a mismatch between the assignment counts
    # and the number of records shown in the table. However, we do not want to delete
    # the Assignment from review (which would correct the mismatch) when it is not found.
    # We cannot be sure that the record not being found in the datastore is intentional
    # or a temporary issue as the a result of a bug.

    before do
      Assigning::AssignToUser.new(
        assignment_id: SecureRandom.uuid,
        user_id: current_user_id,
        to_whom_id: current_user_id
      ).call

      click_on 'Your list'
    end

    it 'shows the assignment in the counts' do
      expect(page).to have_content 'Your list (1)'
      expect(page).to have_content '1 application is assigned to you for review.'
    end
  end
end

require 'rails_helper'

RSpec.describe 'Viewing your assigned application' do
  include_context 'with stubbed search'

  before do
    visit '/'
  end

  context 'when there are no assigned applications' do
    let(:stubbed_search_results) { [] }

    it 'includes the page title' do
      expect(page).to have_content I18n.t('assigned_applications.index.page_title')
    end

    it 'shows shows how many assignments' do
      expect(page).to have_content '0 saved applications'
    end
  end

  context 'when one application is assigned' do
    let(:stubbed_search_results) do
      [
        ApplicationSearchResult.new(
          applicant_name: 'Kit Pound',
          resource_id: '696dd4fd-b619-4637-ab42-a5f4565bcf4a',
          reference: 120_398_120,
          status: 'submitted',
          submitted_at: '2022-10-27T14:09:11.000+00:00'
        )
      ]
    end

    before do
      click_on 'All open applications'
      click_on('Kit Pound')
      click_on('Assign to myself')
      visit '/'
    end

    it 'shows shows how many assignments' do
      expect(page).to have_content '1 saved application'
    end
  end

  context 'when multiple applications are assigned' do
    before do
      click_on 'All open applications'
      click_on('Kit Pound')
      click_on('Assign to myself')
      visit '/applications?status=open'

      click_on('Don JONES')
      click_on('Assign to myself')
      click_on 'Your list'
    end

    it 'shows shows how many assignments' do
      expect(page).to have_content '2 saved application'
    end

    describe 'sortable table headers' do
      subject(:column_sort) do
        page.find('thead tr th#submitted_at')['aria-sort']
      end

      it 'is active and descending by default' do
        expect(column_sort).to eq 'descending'
      end

      context 'when clicked' do
        it 'changes to ascending when it is selected' do
          expect { click_button 'Date received' }.not_to(change { current_path })
          expect(column_sort).to eq 'ascending'
        end
      end
    end
  end

  context 'when using the all applications link' do
    before do
      click_on('View all open applications')
    end

    it 'proceeds to the correct page' do
      expect(page).to have_content 'All open applications'
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
      user = User.where(auth_oid: current_user_auth_oid).first

      Assigning::AssignToUser.new(
        assignment_id: SecureRandom.uuid,
        user_id: user.id,
        to_whom_id: user.id
      ).call

      click_on 'Your list'
    end

    it 'shows the assignment in the counts' do
      expect(page).to have_content 'Your list (1)'
      expect(page).to have_content '0 saved application'
    end
  end
end

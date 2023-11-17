require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  context 'when there is a next application' do
    include_context 'with stubbed assignments and reviews'
    include_context 'when search results are returned'

    before do
      visit '/'

      allow(Allocating).to receive(:user_competencies).with(current_user.id) { current_user_competencies }
    end

    it 'allows you to get the next application' do
      click_on 'Review next application'
      expect(page).to have_content('Kit Pound')
      expect(page).to have_content('Remove from your list')
    end

    it 'searches based on the criminal application team work stream' do
      work_stream = [Types::WorkStreamType['criminal_applications_team']]
      params = ApplicationSearchFilter.new(assigned_status: 'unassigned', work_stream: work_stream).datastore_params
      click_on 'Review next application'

      expect_datastore_to_have_been_searched_with(params, pagination: Pagination.new(limit_value: 1))
    end

    context 'when user is assigned to extradition work stream' do
      let(:current_user_competencies) { [Types::WorkStreamType['extradition']] }

      it 'searches for an extradition application' do
        work_streams_param = [Types::WorkStreamType['extradition']]
        params = ApplicationSearchFilter.new(assigned_status: 'unassigned',
                                             work_stream: work_streams_param).datastore_params
        click_on 'Review next application'

        expect_datastore_to_have_been_searched_with(params, pagination: Pagination.new(limit_value: 1))
      end
    end
  end

  context 'when there is no next application' do
    include_context 'when search results empty'

    it 'shows an error when there is no next application' do
      visit '/'
      click_on 'Review next application'
      expect(page).to have_content('Your list')
      expect(page).to have_content('There are no new applications to be reviewed')
    end
  end
end

require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  context 'when there is a next application' do
    include_context 'with stubbed assignments and reviews'
    include_context 'when search results are returned'

    before do
      visit '/'
    end

    it 'allows you to get the next application' do
      click_on 'Review next application'
      expect(page).to have_content('Kit Pound')
      expect(page).to have_content('Remove from your list')
    end

    describe 'getting next according to competencies' do
      before do
        expected_params
        click_on 'Review next application'
      end

      let(:expected_params) do
        ApplicationSearchFilter.new(
          assigned_status: 'unassigned',
          work_stream: gets_next_from
        ).datastore_params
      end

      context 'when competent in all work streams' do
        let(:current_user_competencies) { Types::WorkStreamType.values }
        let(:gets_next_from) { Types::WorkStreamType.values }

        it 'gets next across all work streams' do
          expect_datastore_to_have_been_searched_with(expected_params, pagination: Pagination.new(limit_value: 1))
        end
      end

      context 'when competent in only one work streams' do
        let(:current_user_competencies) { [Types::WorkStreamType['extradition']] }
        let(:gets_next_from) { [Types::WorkStreamType['extradition']] }

        it 'only gets next from the specified work stream' do
          expect_datastore_to_have_been_searched_with(expected_params, pagination: Pagination.new(limit_value: 1))
        end
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

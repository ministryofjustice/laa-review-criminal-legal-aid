require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  context 'when there is a next application' do
    include_context 'when search results are returned'

    it 'allows you to get the next application' do
      visit '/'
      click_on 'Review next application'
      expect(page).to have_content('Kit Pound')
      expect(page).to have_content('Remove from your list')
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

  context 'when multiple caseworkers attempt to request the same next application to review' do
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

    it 'shows an error when there is no next application' do
      visit '/'
      click_on 'Review next application'
      expect(page).to have_content('Your list')
      expect(page).to have_content('There are no new applications to be reviewed')
    end
  end
end

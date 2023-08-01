require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  context 'when there is a next application' do
    include_context 'with stubbed assignments and reviews'
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
end

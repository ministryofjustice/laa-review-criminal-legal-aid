require 'rails_helper'

RSpec.describe 'Authenticating a signed out user' do
  before do
    click_link 'Sign out'
  end

  context 'when trying to access an existent path' do
    before do
      visit '/assigned_applications'
    end

    it 'the user cannot see the nav' do
      expect(page).not_to have_content 'Closed applications'
    end

    it 'the user cannot access their list' do
      expect(page).not_to have_css('h1.govuk-heading-xl', text: 'Your list')
    end

    it 'informs the user that they need to be signed to access the page requested' do
      expect(page).to have_css('h1.govuk-heading-xl', text: 'Sign in to view this page')
      expect(page).to have_button('Sign in')
    end
  end

  context 'when trying to access an non-existent path' do
    before do
      visit '/foo'
    end

    it 'the user cannot see the nav' do
      expect(page).not_to have_content 'Closed applications'
    end

    it 'informs the user that they need to be signed to access the page requested' do
      expect(page).to have_css('h1.govuk-heading-xl', text: 'Sign in to view this page')
      expect(page).to have_button('Sign in')
    end
  end
end

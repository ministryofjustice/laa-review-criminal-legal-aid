require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  include_context 'with an existing application'
  let(:assign_cta) { 'Assign to your list' }

  before do
    visit '/'
    click_on 'Open applications'
    click_on('Kit Pound')
  end

  it 'shows "Assigned to: no one"' do
    expect(page).to have_content(
      'Assigned to: no one'
    )
  end

  describe 'clicking on "Assign to your list"' do
    before do
      click_on(assign_cta)
    end

    it 'shows success notice' do
      expect(page).to have_content(
        'You assigned this application to your list'
      )
    end

    it 'the "Assign to your list" button is not present' do
      expect(page).not_to have_content(assign_cta)
    end
  end
end

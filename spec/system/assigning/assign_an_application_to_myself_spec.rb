require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  include_context 'with an existing application'
  let(:assign_cta) { 'Assign to myself' }

  before do
    visit '/'
    click_on 'All open applications'
    click_on('Kit Pound')
  end

  it 'shows "Assigned to Unassigned"' do
    expect(page).to have_content(
      'Assigned to: Unassigned'
    )
  end

  describe 'clicking on "Assign to myself"' do
    before do
      click_on(assign_cta)
    end

    it 'shows success notice' do
      expect(page).to have_content(
        'This application has been assigned to you'
      )
    end

    it 'the "Assign to myself" button is not present' do
      expect(page).not_to have_content(assign_cta)
    end
  end
end

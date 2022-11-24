require 'rails_helper'

RSpec.describe 'Viewing application history' do
  before do
    visit '/'
    click_on 'All open applications'
    click_on('Kit Pound')
  end

  context 'with a submitted application' do
    before do
      click_on('Application history')
    end

    it 'includes the submission event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Monday 24 Oct 09:33 Provider Name Application submitted')
    end
  end

  context 'with an assigned application' do
    before do
      click_on('Assign to myself')
      click_on('Application history')
    end

    it 'includes the submission event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Joe EXAMPLE Application assigned to Joe EXAMPLE')
    end
  end

  context 'with an unassigned application' do
    before do
      click_on('Assign to myself')
      click_on('Remove from your list')
      click_on 'All open applications'
      click_on('Kit Pound')
      click_on('Application history')
    end

    it 'includes the submission event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Joe EXAMPLE Application removed from Joe EXAMPLE')
    end
  end
end

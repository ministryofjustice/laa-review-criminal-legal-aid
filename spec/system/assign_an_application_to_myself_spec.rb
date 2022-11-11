require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  before do
    visit '/applications'
    click_on('Kit Pound')
  end

  context 'with an unassigned application' do
    it 'is assigned to unassigned' do
      expect(page).to have_content(
        'unassigned'
      )
    end

    context 'when click on Assign to myself' do
      before do
        click_on('Assign to myself')
      end

      it 'includes the users details' do
        expect(page).to have_content(
          'This application has been assigned to you'
        )
      end
    end
  end
end

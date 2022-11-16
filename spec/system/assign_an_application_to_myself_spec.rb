require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  before do
    visit '/applications'
    click_on('Kit Pound')
  end

  let(:assign_cta) { 'Assign to myself' }

  context 'with an unassigned application' do
    it 'is assigned to unassigned' do
      expect(page).to have_content(
        'Unassigned'
      )
    end

    context 'when click on Assign to myself' do
      before do
        click_on(assign_cta)
      end

      it 'includes the users details' do
        expect(page).to have_content(
          'This application has been assigned to you'
        )
      end

      it 'the Assign to self button is not there' do
        expect(page).not_to have_content(assign_cta)
      end
    end
  end
end

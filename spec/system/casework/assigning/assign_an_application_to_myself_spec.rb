require 'rails_helper'

RSpec.describe 'Assigning an application to myself' do
  include_context 'with an existing application'
  let(:assign_cta) { 'Assign to your list' }
  let(:banner_text) do
    "You must be allocated to the CAT 1 work queue to review this application\nContact your supervisor to arrange this"
  end

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
    let(:current_user_competencies) { [Types::WorkStreamType['criminal_applications_team']] }

    before do
      click_on(assign_cta)
    end

    it 'shows success notice' do
      expect(page).to have_content(
        'You assigned this application to your list'
      )
    end

    it 'the "Assign to your list" button is not present' do
      expect(page).to have_no_content(assign_cta)
    end

    context 'when you are not allocated to the correct work stream' do
      let(:current_user_competencies) { [Types::WorkStreamType['extradition']] }

      it 'displays a notification banner' do
        click_on(assign_cta)
        expect(page).to have_content banner_text
      end
    end
  end
end

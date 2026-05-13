require 'rails_helper'

RSpec.describe 'Reassigning an application to myself' do
  include_context 'with an assigned application'

  let(:banner_text) do
    "You must be allocated to the CAT 1 work queue to review this application\nContact your supervisor to arrange this"
  end

  before do
    click_on 'Open applications'
    click_on('Kit Pound')
  end

  it 'shows "Assigned to: Assignee Name"' do
    expect(page).to have_content("Assigned to: #{assignee.name}")
  end

  describe 'clicking on "Reassign to your list"' do
    before do
      click_on('Reassign to your list')
    end

    it 'prompts to confirm the action' do
      expect(page).to have_content(
        'Confirm you want to reassign this application to your list'
      )
    end

    context 'when you are not allocated to the correct work stream' do
      let(:current_user_competencies) { [Types::WorkStreamType['extradition']] }

      it 'displays a notification banner' do
        expect(page).to have_content banner_text
      end
    end

    describe 'clicking on "Reassign application"' do
      it 'redirects to the application details' do
        expect { click_on('Reassign application') }.to change { page.current_path }
          .from(confirm_path)
          .to(crime_application_path(crime_application_id))
      end

      it 'shows the success notice' do
        click_on('Reassign application')

        within('.govuk-notification-banner--success') do
          expect(page).to have_content('You assigned this application to your list')
        end
      end

      it 'assigns to the current user' do
        click_on('Reassign application')
        expect(page).to have_content 'Assigned to: Joe EXAMPLE'
      end
    end

    describe 'clicking on "Back to application"' do
      it 'redirects to application details' do
        expect { click_on('Back to application') }.to change { page.current_path }
          .from(confirm_path).to(
            crime_application_path(crime_application_id)
          )
      end

      it 'does not reassign' do
        click_on('Back to application')
        expect(page).to have_content 'Assigned to: Fred Smitheg'
      end
    end
  end
end

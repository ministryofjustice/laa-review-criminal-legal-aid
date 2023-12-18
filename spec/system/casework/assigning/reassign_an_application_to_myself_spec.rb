require 'rails_helper'

RSpec.describe 'Reassigning an application to myself' do
  include_context 'with an assigned application'

  let(:banner_text) do
    "You must be allocated to the Cat 1 work queue to review this application\nContact your supervisor to arrange this"
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
        'Are you sure you want to reassign this application from Fred Smitheg to your list?'
      )
    end

    it 'warns about the impact of reassigning' do
      within('div.govuk-warning-text') do
        expect(page).to have_content(
          "!WarningThis will remove the application from your colleague's list"
        )
      end
    end

    describe 'clicking on "Yes, reassign"' do
      it 'redirects to the application details' do
        expect { click_on('Yes, reassign') }.to change { page.current_path }
          .from(confirm_path)
          .to(crime_application_path(crime_application_id))
      end

      it 'shows the success notice' do
        click_on('Yes, reassign')

        within('.govuk-notification-banner--success') do
          expect(page).to have_content('You assigned this application to your list')
        end
      end

      it 'assigns to the current user' do
        click_on('Yes, reassign')
        expect(page).to have_content 'Assigned to: Joe EXAMPLE'
      end
    end

    describe 'clicking on "No, do not reassign"' do
      it 'redirects to application details' do
        expect { click_on('No, do not reassign') }.to change { page.current_path }
          .from(confirm_path).to(
            crime_application_path(crime_application_id)
          )
      end

      it 'does not reassign' do
        click_on('No, do not reassign')
        expect(page).to have_content 'Assigned to: Fred Smitheg'
      end
    end

    context 'when you are not allocated to the correct work stream' do
      let(:current_user_competencies) { [Types::WorkStreamType['extradition']] }

      it 'displays a notification banner' do
        click_on('Yes, reassign')
        expect(page).to have_content banner_text
      end
    end
  end
end

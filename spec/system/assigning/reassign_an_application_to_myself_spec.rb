require 'rails_helper'

RSpec.describe 'Reassigning an application to myself' do
  include_context 'with an existing application'
  let(:confirm_path) do
    new_crime_application_reassign_path(crime_application_id)
  end

  let(:assignee) do
    User.create(
      first_name: 'Fred',
      last_name: 'Smitheg',
      auth_oid: SecureRandom.uuid,
      email: 'Fred.Smitheg@justice.gov.uk'
    )
  end

  before do
    Assigning::AssignToUser.new(
      user_id: assignee.id,
      to_whom_id: assignee.id,
      assignment_id: crime_application_id
    ).call

    visit '/'
    click_on 'All open applications'
    click_on('Kit Pound')
  end

  it 'shows "Assigned to: Assignee Name"' do
    expect(page).to have_content("Assigned to: #{assignee.name}")
  end

  describe 'clicking on "Reassign to myself"' do
    before do
      click_on('Reassign to myself')
    end

    it 'prompts to confirm the action' do
      expect(page).to have_content(
        'Are you sure you want to reassign this application from Fred Smitheg to your list?'
      )
    end

    it 'warns about the impact of reassigning' do
      within('div.govuk-warning-text') do
        expect(page).to have_content(
          "! Warning This will remove the application from your colleague's list"
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
          expect(page).to have_content('This application has been assigned to you')
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
  end
end

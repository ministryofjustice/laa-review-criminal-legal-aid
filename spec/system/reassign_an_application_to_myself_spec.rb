require 'rails_helper'

RSpec.describe 'Reassigning an application to myself' do
  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:confirm_path) do
    new_crime_application_reassign_path(crime_application_id)
  end

  let(:assignee) do
    User.new(
      first_name: 'Fred',
      last_name: 'Smitheg',
      id: SecureRandom.uuid,
      email: 'Fred.Smitheg@justice.gov.uk',
      roles: ['supervisor']
    )
  end

  before do
    Assigning::AssignToSelf.new(
      user: assignee,
      crime_application_id: crime_application_id
    ).call

    visit '/'
    click_on 'All open applications'
    click_on('Kit Pound')

    # So we can simulate what would happen on production
    allow(
      Rails.application.config
    ).to receive(:consider_all_requests_local).and_return(false)
  end

  it 'shows "Assigned to Assignee Name"' do
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

    it 'warns about the effect of reassigning' do
      within('div.govuk-warning-text') do
        expect(page).to have_content(
          "! Warning This will remove the application from your colleague's list"
        )
      end
    end

    describe 'clicking on "Yes, reassign"' do
      it 'redirects to the application details' do
        expect { click_on('Yes, reassign') }.to change(page, :current_path)
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

    context 'when the application is reassigned to another before confirming reassign' do
      let(:another) do
        User.new(
          first_name: 'Fast',
          last_name: 'Janeeg',
          id: SecureRandom.uuid,
          email: 'Fast.Janeeg@justice.gov.uk',
          roles: ['caseworker']
        )
      end

      let(:reassign_to_another) do
        Assigning::ReassignToSelf.new(
          crime_application_id: crime_application_id,
          user: another,
          state_key: CurrentAssignment.new(crime_application_id:).state_key
        ).call
      end

      it 'notifies that the assignment had already happened' do
        reassign_to_another

        click_on('Yes, reassign')
        within('.govuk-notification-banner--important') do
          expect(page).to have_content('This application has already been assigned to someone else.')
        end
      end

      it 'redirects to the application details page' do
        reassign_to_another

        expect { click_on('Yes, reassign') }.to change(page, :current_path)
          .from(confirm_path).to(
            crime_application_path(crime_application_id)
          )
      end

      it 'does not reassign' do
        reassign_to_another

        click_on('Yes, reassign')
        expect(page).to have_content 'Assigned to: Fast Janeeg'
      end
    end

    describe 'clicking on "No, do not reassign"' do
      it 'redirects to application details' do
        expect { click_on('No, do not reassign') }.to change(page, :current_path)
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

  describe 'attempting to reassign an unassigned application' do
    before do
      Assigning::UnassignFromSelf.new(
        user: assignee,
        crime_application_id: crime_application_id
      ).call
    end

    it 'returns not found' do
      visit(confirm_path)
      expect(page).to have_content 'Sorry, something went wrong'
    end
  end
end

require 'rails_helper'

RSpec.describe 'Send an application back to the provider' do
  include_context 'with stubbed search'

  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:new_return_path) do
    new_crime_application_return_path(crime_application_id)
  end

  let(:send_back_cta) { 'Send back to provider' }

  before do
    visit '/'
  end

  context 'when assigned to the application' do
    let(:assignee_id) { User.find_by(auth_oid: current_user_auth_oid).id }

    before do
      Assigning::AssignToUser.new(
        assignment_id: crime_application_id,
        user_id: assignee_id,
        to_whom_id: assignee_id
      ).call

      click_on 'All open applications'
      click_on('Kit Pound')
    end

    it 'the "Send back to provider" button is visable and accessible' do
      expect { click_button(send_back_cta) }.to change { page.current_path }
        .from(crime_application_path(crime_application_id)).to(
          new_return_path
        )
    end

    describe 'adding the return reason' do
      before do
        allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
          .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))
        click_button(send_back_cta)
      end

      it 'shows the applicant name in the heading' do
        expect(page).to have_content "Send Kit Pound's application back to the provider"
      end

      it 'requires further details' do
        choose 'Duplicate application'
        fill_in 'return-details-details-field', with: ''
        click_button(send_back_cta)

        within '.govuk-error-summary__body' do
          expect(page).to have_content 'Give further details'
        end
      end

      it 'requires a reason to be selected' do
        fill_in 'return-details-details-field', with: 'This application was duplicated'
        click_button(send_back_cta)

        within '.govuk-error-summary__body' do
          expect(page).to have_content 'Choose a reason'
        end
      end

      it 'returns to the application and notifies the caseworker' do
        choose 'Duplicate application'
        fill_in 'return-details-details-field', with: 'This application was duplicated'
        click_button(send_back_cta)

        expect(page).to have_content 'The application has been sent back to the provider'
      end
    end
  end

  context 'when not assigned to the application' do
    let(:assignee_id) do
      User.create(auth_oid: SecureRandom.uuid, first_name: 'A', last_name: 'Caseworder').id
    end

    before do
      click_on 'All open applications'
      click_on('Kit Pound')
    end

    it 'the "Send back to provider" button is not visable' do
      expect(page).not_to have_button(send_back_cta)
    end
  end

  context 'with errors Reviewing::' do
    before do
      visit new_return_path
      command_double = instance_double(Reviewing::SendBack)

      allow(command_double).to receive(:call) { raise error_class }

      allow(Reviewing::SendBack).to receive(:new) { command_double }

      choose 'Duplicate application'
      fill_in 'return-details-details-field', with: 'This application was duplicated'

      click_button(send_back_cta)
    end

    describe 'AlreadySentBack' do
      let(:error_class) { Reviewing::AlreadySentBack }
      let(:message) do
        'This application has already been sent back to the provider'
      end

      it 'notifies that the application has already been sent back' do
        expect(page).to have_content message
      end
    end

    describe 'CannotSendBackWhenCompleted' do
      let(:error_class) { Reviewing::CannotSendBackWhenCompleted }
      let(:message) { 'This application has already been completed' }

      it 'notifies that the application has already been completed' do
        expect(page).to have_content message
      end
    end
  end
end

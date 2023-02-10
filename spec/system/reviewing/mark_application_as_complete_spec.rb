
require 'rails_helper'

RSpec.describe 'Marking an application as complete' do
  include_context 'with stubbed search'

  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:new_return_path) do
    new_crime_application_return_path(crime_application_id)
  end

  let(:mark_application_as_complete) { 'Mark as complete' }

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

      click_on 'Your list'
      click_on 'Kit Pound'
    end

    it 'the "Mark as complete" button is visable and accessible' do
      expect { click_button(send_back_cta) }.to change { page.current_path }
        .from(crime_application_path(crime_application_id)).to(
          new_return_path
        )
    end

    # describe 'clicking the link' do
    #   descibe 'when successful' do
      #   before do
      #     click link
      #   end
    #
      #   it 'should flash a success message to the user' do
      #      # expect page to have correct flash message
      #   end
      #
      #   it 'should reflect the status change on the application show page' do
      #   end
    #   end
    #
    #   descibe 'when unsuccessful' do
      #   before do
      #     click link
      #   end
      #   it 'should flash an unsuccessful message to the user' do
      #      # expect page to have correct flash message
      #   end
      #
      #   it 'should not change the status on the application show page' do
      #   end
    #   end
    # end

    # context 'with errors Closing::' do
    #   ... closing specific errors
    # end
  end
end

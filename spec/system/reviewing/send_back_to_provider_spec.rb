require 'rails_helper'

RSpec.describe 'Send an application back to the provider' do
  include_context 'with stubbed search'

  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:confirm_path) do
    new_crime_application_return_path(crime_application_id)
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
    click_on('Return')
  end

  describe 'reloading the confirm page after a assignment has been unassigned' do
    before do
      CurrentAssignment.delete_all
      visit current_path
    end

    it 'returns not found' do
      expect(page).to have_content(
        'Page not found'
      )
    end
  end
end

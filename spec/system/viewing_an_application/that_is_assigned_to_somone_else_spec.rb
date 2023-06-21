require 'rails_helper'

RSpec.describe 'Viewing an application that is assigned to someone else' do
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
    visit '/'

    user = User.create!(
      first_name: 'Fred',
      last_name: 'Smitheg',
      email: 'Fred.Smitheg@eg.com',
      auth_oid: '976658f9-f3d5-49ec-b0a9-485ff8b308fa'
    )

    Assigning::AssignToUser.new(
      user_id: user.id,
      to_whom_id: user.id,
      assignment_id: application_id
    ).call

    visit crime_application_path(application_id)
  end

  it 'includes the name of the assigned user' do
    expect(page).to have_content('Assigned to: Fred Smitheg')
  end

  it 'includes button to reassign' do
    expect(page).to have_content('Reassign to your list')
  end

  it 'does not show the review buttons' do
    expect(page).not_to have_content('Mark as ready for MAAT')
    expect(page).not_to have_content('Mark as completed')
  end
end

require 'rails_helper'

RSpec.describe 'Crime applications' do
  include Devise::Test::IntegrationHelpers
  include_context 'with stubbed application'

  let(:data_analyst_user) do
    User.create!(
      first_name: 'Data',
      last_name: 'Analyst',
      email: "data-analyst-#{SecureRandom.hex(4)}@example.com",
      auth_subject_id: SecureRandom.uuid,
      can_manage_others: false,
      role: UserRole::DATA_ANALYST
    )
  end

  before do
    sign_in data_analyst_user
  end

  describe 'ready' do
    before do
      Assigning::AssignToUser.new(
        assignment_id: application_id, user_id: data_analyst_user.id,
        to_whom_id: data_analyst_user.id, reference: 100_123
      ).call

      put "/applications/#{application_id}/ready"
    end

    it 'sets the correct flash message and redirects' do
      expect(flash[:important]).to eq(['You must be a caseworker or supervisor to review an application'])
      expect(response).to redirect_to("/applications/#{application_id}")
    end
  end
end

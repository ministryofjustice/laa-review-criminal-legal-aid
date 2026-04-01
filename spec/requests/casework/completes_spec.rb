require 'rails_helper'

RSpec.describe 'Completing applications' do
  include_context 'with stubbed application'
  include_context 'with an existing supervisor user'

  before do
    sign_in supervisor_user
  end

  describe 'create' do
    before do
      Assigning::AssignToUser.new(
        assignment_id: application_id, user_id: supervisor_user.id,
        to_whom_id: supervisor_user.id, reference: 100_123
      ).call

      post "/applications/#{application_id}/complete"
    end

    it 'sets the correct flash message and redirects' do
      expect(flash[:important]).to eq(['You must be a caseworker to review an application'])
      expect(response).to redirect_to("/applications/#{application_id}")
    end
  end
end

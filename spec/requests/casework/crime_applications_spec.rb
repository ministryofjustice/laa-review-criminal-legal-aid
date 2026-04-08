require 'rails_helper'

RSpec.describe 'Crime applications' do
  include_context 'with stubbed application'
  include_context 'with an existing supervisor user'

  before do
    sign_in supervisor_user
  end

  describe 'ready' do
    before do
      Assigning::AssignToUser.new(
        assignment_id: application_id, user_id: supervisor_user.id,
        to_whom_id: supervisor_user.id, reference: 100_123
      ).call

      put "/applications/#{application_id}/ready"
    end

    it 'sets the correct flash message and redirects' do
      expect(flash[:important]).to eq(['You must be a caseworker to review an application'])
      expect(response).to redirect_to("/applications/#{application_id}")
    end
  end
end

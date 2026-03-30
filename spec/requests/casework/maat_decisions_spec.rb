require 'rails_helper'

RSpec.describe 'MAAT decisions' do
  include_context 'with stubbed application'
  include_context 'with a supervisor user'

  before do
    sign_in supervisor_user
  end

  describe 'new' do
    before do
      Assigning::AssignToUser.new(
        assignment_id: application_id, user_id: supervisor_user.id,
        to_whom_id: supervisor_user.id, reference: 100_123
      ).call

      get "/applications/#{application_id}/link-maat-id"
    end

    it 'sets the correct flash message and redirects' do
      expect(flash[:important]).to eq(['You must be a caseworker to review'])
      expect(response).to redirect_to("/applications/#{application_id}")
    end
  end

  describe 'create' do
    before do
      Assigning::AssignToUser.new(
        assignment_id: application_id, user_id: supervisor_user.id,
        to_whom_id: supervisor_user.id, reference: 100_123
      ).call

      post "/applications/#{application_id}/link-maat-id", params: { maat_id_form: { maat_id: '123456' } }
    end

    it 'sets the correct flash message and redirects' do
      expect(flash[:important]).to eq(['You must be a caseworker to review'])
      expect(response).to redirect_to("/applications/#{application_id}")
    end
  end

  describe 'create_by_reference' do
    before do
      Assigning::AssignToUser.new(
        assignment_id: application_id, user_id: supervisor_user.id,
        to_whom_id: supervisor_user.id, reference: 100_123
      ).call

      post "/applications/#{application_id}/maat_decisions/create_by_reference"
    end

    it 'sets the correct flash message and redirects' do
      expect(flash[:important]).to eq(['You must be a caseworker to review'])
      expect(response).to redirect_to("/applications/#{application_id}")
    end
  end
end

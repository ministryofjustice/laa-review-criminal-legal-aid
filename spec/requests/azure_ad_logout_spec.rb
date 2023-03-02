require 'rails_helper'

RSpec.describe 'OmniAuth Endpoints' do
  include_context 'with a logged in user'

  let(:user_id) do
    current_user_id
  end

  describe "GET '/auth/azure_ad/callback'" do
    before do
      get 'https://www.example.com/auth/azure_ad/callback'
    end

    let(:user) { User.find(request.env['warden'].user['id']) }

    it 'authenticates the user' do
      expect(request.env['warden'].authenticated?(:user)).to be true
    end

    it 'sets the current user id' do
      expect(user.auth_oid).to eq current_user_auth_oid
    end

    it 'sets the current user name' do
      expect(user.name).to eq 'Joe EXAMPLE'
    end

    it 'redirects to root' do
      expect(response).to redirect_to root_path
    end
  end

  describe "GET '/auth/azure_ad'" do
    before do
      get 'https://www.example.com/auth/azure_ad'
    end

    it 'redirects for authorization' do
      expect(response).to have_http_status :found
    end
  end

  describe "GET '/logout'" do
    before do
      get 'https://www.example.com/logout'
    end

    it 'returns status OK' do
      expect(response).to have_http_status :ok
    end
  end
end

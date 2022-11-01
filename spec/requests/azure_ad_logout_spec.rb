require 'rails_helper'

RSpec.describe 'OmniAuth Endpoints' do
  describe "GET '/auth/azure_ad/callback'" do
    before do
      get 'https://www.example.com/auth/azure_ad/callback'
    end

    let(:user) { request.env['warden'].user }

    it 'authenticates the user' do
      expect(request.env['warden'].authenticated?(:user)).to be true
    end

    it 'sets the current user id' do
      expect(user.id).to eq '123456789'
    end

    it 'sets the current user name' do
      expect(user.name).to eq 'Joe EXAMPLE'
    end

    it 'sets the current user roles' do
      expect(user.roles).to eq ['caseworker']
    end

    it 'sets the current users email' do
      expect(user.email).to eq 'Joe.EXAMPLE@justice.gov.uk'
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

require 'rails_helper'

RSpec.describe 'OmniAuth Endpoints' do
  include_context 'with a logged in user'

  describe "GET '/auth/azure_ad/callback'" do
    let(:callback) do
      get 'https://www.example.com/auth/azure_ad/callback'
    end

    let(:user) { User.find(current_user_id) }

    it 'authenticates the user' do
      callback
      expect(request.env['warden'].authenticated?(:user)).to be true
    end

    it 'sets the current user subject id' do
      expect { callback }.to change { user.reload.auth_subject_id }
        .from(nil)
        .to(current_user_auth_subject_id)
    end

    it 'sets the current user\'s last_auth_at' do
      expect { callback }.to change { user.reload.last_auth_at }.from(nil)
    end

    it 'sets the current user\'s first_auth_at' do
      expect { callback }.to change { user.reload.first_auth_at }.from(nil)
    end

    it 'sets the current user name' do
      expect { callback }.to change { user.reload.name }.from(' ').to('Joe EXAMPLE')
    end

    it 'redirects to root' do
      callback
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

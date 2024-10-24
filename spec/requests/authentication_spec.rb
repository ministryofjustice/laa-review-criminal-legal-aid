require 'rails_helper'

RSpec.describe 'Authentication Session Initialisation' do
  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  include Devise::Test::IntegrationHelpers

  let(:auth_callback) do
    get 'https://www.example.com/users/auth/azure_ad/callback'
  end

  describe 'an initial request to a protected part of the site' do
    it 'authenticates the user with Azure Ad' do
      get closed_crime_applications_path
      expect(response).to redirect_to(unauthenticated_root_path)
    end
  end

  context 'when user info is returned by Azure Ad' do
    let(:auth_subject_id) { "#{SecureRandom.hex(16)}_ABde1" }
    let(:expires_in) { 1.minute }

    before do
      auth_hash = {
        provider: 'azure_ad',
        uid: auth_subject_id,
        credentials: { expires_in: },
        info: {
          email: 'Ben.EXAMPLE@example.com',
          first_name: 'Ben',
          last_name: 'EXAMPLE'
        }
      }

      OmniAuth.config.mock_auth[:azure_ad] = OmniAuth::AuthHash.new(auth_hash)
    end

    describe 'when the user does not exist in the review database' do
      it 'responds with "Access to this service is restricted' do
        auth_callback

        expect(response.body).to include 'Access to this service is restricted'
      end
    end

    describe 'when the user is pending authentication' do
      let(:user) { User.create(email: 'Ben.EXAMPLE@example.com', role: UserRole::CASEWORKER) }

      before { user }

      it 'redirects to "Your list"' do
        auth_callback
        expect(response).to redirect_to(assigned_applications_path)
      end

      it 'authenticates the user' do
        auth_callback
        expect(request.env['warden'].authenticated?(:user)).to be true
      end

      it 'sets the current user subject id' do
        expect { auth_callback }.to(
          change { user.reload.auth_subject_id }.from(nil).to(auth_subject_id)
        )
      end

      it 'sets the current user\'s last_auth_at' do
        expect { auth_callback }.to(
          change { user.reload.last_auth_at }.from(nil)
        )
      end

      it 'sets the current user\'s first_auth_at' do
        expect { auth_callback }.to(
          change { user.reload.first_auth_at }.from(nil)
        )
      end

      it 'sets the current user name' do
        expect { auth_callback }.to(
          change { user.reload.name }.from('').to('Ben EXAMPLE')
        )
      end
    end

    describe 'when the user is an activated user' do
      let(:user) do
        User.create(auth_subject_id: auth_subject_id, email: 'test@eg.com')
      end

      before { user }

      it 'authenticates the user' do
        auth_callback
        expect(request.env['warden'].authenticated?(:user)).to be true
      end

      it 'does not change the auth_subject_id' do
        expect { auth_callback }.not_to(
          change { user.reload.auth_subject_id }
        )
      end

      it 'does not change the auth_oid' do
        expect { auth_callback }.not_to(
          change { user.reload.auth_oid }
        )
      end

      it 'does not change the first_auth_at' do
        expect { auth_callback }.not_to(
          change { user.reload.first_auth_at }
        )
      end

      it 'sets the current user\'s last_auth_at' do
        expect { auth_callback }.to(
          change { user.reload.last_auth_at }.from(nil)
        )
      end

      it 'sets the current user name' do
        expect { auth_callback }.to(
          change { user.reload.name }.from('').to('Ben EXAMPLE')
        )
      end

      context 'when user is a `user_manager`' do
        let(:user) do
          User.create(auth_subject_id: auth_subject_id, email: 'test@eg.com', can_manage_others: true)
        end

        it 'redirects to "Manage Users"' do
          auth_callback

          expect(response).to redirect_to(manage_users_root_path)
        end
      end

      context 'when user is a `caseworker`' do
        let(:user) do
          User.create(auth_subject_id: auth_subject_id, email: 'test@eg.com', role: UserRole::CASEWORKER)
        end

        it 'redirects to "Your list"' do
          auth_callback
          expect(response).to redirect_to(assigned_applications_path)
        end
      end

      context 'when user is a `supervisor`' do
        let(:user) do
          User.create(auth_subject_id: auth_subject_id, email: 'test@eg.com', role: UserRole::SUPERVISOR)
        end

        it 'redirects to "Your list"' do
          auth_callback
          expect(response).to redirect_to(assigned_applications_path)
        end
      end

      context 'when user is a `data_analyst`' do
        let(:user) do
          User.create(auth_subject_id: auth_subject_id, email: 'test@eg.com', role: UserRole::DATA_ANALYST)
        end

        it 'redirects to "Your list"' do
          auth_callback
          expect(response).to redirect_to(new_application_searches_path)
        end
      end
    end
  end

  context 'when user id_token is invalid' do
    let(:auth_subject_id) { SecureRandom.uuid }
    let(:auth_oid) { SecureRandom.uuid }

    before do
      OmniAuth.config.mock_auth[:azure_ad] = :access_denied
    end

    it 'redirects to the omniauth failure endpoint' do
      auth_callback

      expect(response.body).to include 'Access to this service is restricted'
    end
  end

  context 'when a GET request is made to the user auth path' do
    it 'returns page not found' do
      get user_azure_ad_omniauth_authorize_path

      expect(response).to have_http_status(:not_found)
    end
  end
end

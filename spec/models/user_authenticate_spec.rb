require 'rails_helper'

RSpec.describe UserAuthenticate do
  describe '.authenticate!' do
    subject(:authenticate!) { described_class.new(auth_hash).authenticate! }

    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        {
          uid: SecureRandom.uuid,
        info: {
          email: 'test@example.com',
          first_name: 'Jo',
          last_name: 'TEST'
        }
        }
      )
    end

    before do
      auth_hash
    end

    context 'when user does not exist in database' do
      it { is_expected.to be_nil }
    end

    context 'when an active user is found' do
      let(:user) do
        User.create!(
          auth_subject_id: auth_hash.uid,
          email: 'test1@example.com',
          last_auth_at: '2023-05-04'
        )
      end

      before do
        user
      end

      it 'returns the active user' do
        expect(authenticate!).to eq user
      end

      it "updates the user's name" do
        expect { authenticate! }.to(
          change { user.reload.name }.from('').to('Jo TEST')
        )
      end

      it "updates the user's email" do
        expect { authenticate! }.to(
          change { user.reload.email }.from('test1@example.com').to('test@example.com')
        )
      end

      it "sets the user's last_auth_at" do
        expect { authenticate! }.to(
          change { user.reload.last_auth_at }
        )
      end

      it "does not change the user's first_auth_at" do
        expect { authenticate! }.not_to(
          change { user.reload.first_auth_at }
        )
      end

      context 'when the user is deactivated' do
        before do
          user.deactivate!
        end

        it 'returns nil' do
          expect(authenticate!).to be_nil
        end
      end
    end

    context 'when an invided user is found' do
      let(:user) do
        User.create!(email: 'test@example.com')
      end

      before do
        user
      end

      it 'activates the user' do
        expect { authenticate! }.to(
          change { user.reload.activated? }.from(false).to(true)
        )
      end

      it 'returns the active user' do
        expect(authenticate!).to eq user
      end

      it "updates the user's name" do
        expect { authenticate! }.to(
          change { user.reload.name }.from('').to('Jo TEST')
        )
      end

      it "sets the user's last_auth_at" do
        expect { authenticate! }.to(
          change { user.reload.last_auth_at }
        )
      end

      it "sets the user's auth_subject_id" do
        expect { authenticate! }.to(
          change { user.reload.auth_subject_id }.from(nil).to(auth_hash.uid)
        )
      end

      it "sets the user's first_auth_at" do
        expect { authenticate! }.to(
          change { user.reload.first_auth_at }
        )
      end

      context 'when the user\'s invitation has expired' do
        before do
          user.update(invitation_expires_at: Time.zone.now)
        end

        it 'returns nil' do
          expect(authenticate!).to be_nil
        end

        it 'does not activate the user' do
          expect { authenticate! }.not_to change { user.reload.auth_subject_id }.from(nil)
        end
      end
    end

    context 'with an activated user with the same email but different auth subject id' do
      let(:user) do
        User.create(auth_subject_id: SecureRandom.uuid, email: 'test@example.com')
      end

      before do
        user
      end

      it 'returns nil' do
        expect(authenticate!).to be_nil
      end
    end
  end
end

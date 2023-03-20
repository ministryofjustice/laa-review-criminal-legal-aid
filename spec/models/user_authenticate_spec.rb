require 'rails_helper'

RSpec.describe UserAuthenticate do
  describe '.authenticate!' do
    subject(:authenticate!) { described_class.new(auth_hash).authenticate! }

    let(:auth_expires_at) { expires_in.from_now }
    let(:expires_in) { 1.minute }

    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        {
          uid: SecureRandom.uuid,
        info: {
          email: 'test@example.com',
          first_name: 'Jo',
          last_name: 'TEST'
        },
        credentials: {
          expires_in:
        }
        }
      )
    end

    context 'when user does not exist in database' do
      it { is_expected.to be_nil }
    end

    context 'when an active user is found' do
      let(:user) do
        instance_double(
          User,
          update!: true,
          pending_authentication?: false,
          deactivated?: false
        )
      end

      let(:expected_attributes) do
        {
          first_name: 'Jo',
          last_name: 'TEST',
          email: 'test@example.com',
          last_auth_at: Time.zone.now,
          auth_expires_at: auth_expires_at
        }
      end

      before do
        freeze_time
        allow(User).to receive(:find_by).with(
          { auth_subject_id: auth_hash.uid }
        ).and_return user
      end

      it 'returns the active user' do
        expect(authenticate!).to be user
      end

      it "sets the user's name, email and last_auth_at" do
        authenticate!
        expect(user).to have_received(:update!).with expected_attributes
      end

      context 'when the user is deactivated' do
        let(:user) { instance_double(User, deactivated?: true) }

        it 'returns nil' do
          expect(authenticate!).to be_nil
        end
      end
    end

    context 'when a user pending_activation is found' do
      let(:user) do
        instance_double(
          User,
          update!: true,
          pending_authentication?: true,
          deactivated?: false
        )
      end

      let(:expected_attributes) do
        {
          first_name: 'Jo',
          last_name: 'TEST',
          auth_subject_id: auth_hash.uid,
          auth_expires_at: auth_expires_at,
          email: auth_hash.info.email,
          first_auth_at: Time.zone.now,
          last_auth_at: Time.zone.now
        }
      end

      before do
        freeze_time

        allow(User).to receive(:find_by).with(auth_subject_id: auth_hash.uid).and_return(nil)

        allow(User).to receive(:find_by).with(email: auth_hash.info.email) { user }
      end

      it 'returns the active user' do
        expect(authenticate!).to be user
      end

      it "sets the user's name, auth_oid, first_auth_at and last_auth_at" do
        authenticate!
        expect(user).to have_received(:update!).with(expected_attributes)
      end

      context 'when the user is deactivated' do
        before do
          allow(user).to receive(:deactivated?).and_return true
        end

        it 'returns nil' do
          expect(authenticate!).to be_nil
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe UserAuthenticate do
  describe '.authenticate' do
    subject(:authenticate) { described_class.new(auth_hash).authenticate }

    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        {
          uid: SecureRandom.uuid,
        info: {
          email: 'test@example.com',
        }
        }
      )
    end

    let(:user) { nil }

    before { user }

    context 'when user does not exist in database' do
      it { is_expected.to be_nil }
    end

    context 'when the user is active' do
      let(:user) do
        User.create!(
          auth_subject_id: auth_hash.uid,
          email: 'test1@example.com',
          last_auth_at: 1.day.ago,
          first_auth_at: 1.week.ago
        )
      end

      it 'returns the user' do
        expect(authenticate).to eq user
      end

      context 'when the user is deactivated' do
        before do
          # NOTE: Require at least 2 admins to deactivate another user
          2.times do |i|
            User.create!(can_manage_others: true, auth_subject_id: SecureRandom.uuid, email: "test2#{i}@eg.com")
          end

          user.deactivate!
        end

        it 'returns nil' do
          expect(authenticate).to be_nil
        end
      end
    end

    context 'when the user is pending activation' do
      let(:user) { User.create!(email: 'test@example.com') }

      it 'returns the user' do
        expect(authenticate).to eq user
      end
    end

    # Spec to ensure that a user with the same email cannot be linked if its
    # auth subject id has been set.
    context 'when an activated user with the same email but different sub exists' do
      let(:user) do
        User.create(auth_subject_id: SecureRandom.uuid, email: 'test@example.com')
      end

      it 'returns nil' do
        expect(authenticate).to be_nil
      end
    end
  end
end

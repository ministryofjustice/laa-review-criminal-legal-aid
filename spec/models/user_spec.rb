require 'rails_helper'

RSpec.describe User do
  let(:activated_user) do
    described_class.create(auth_subject_id: SecureRandom.uuid, email: 'active.example@example.com',
                           first_auth_at: Time.zone.now)
  end
  let(:invited_user) { described_class.create(email: 'invited.example@example.com') }

  it_behaves_like 'a reauthable model'

  describe '#deactivate!' do
    let(:user) { activated_user }

    context 'when database has at least 2 other active admin users' do
      it 'deactivates a user' do
        2.times do |i|
          described_class.create!(can_manage_others: true, auth_subject_id: SecureRandom.uuid,
                                  email: "test2#{i}@example.com")
        end

        expect { user.deactivate! }.to change { user.deactivated? }.from(false).to(true)
      end
    end

    context 'when database has fewer than 2 other active admin users' do
      it 'does not deactivate a user' do
        described_class.create!(can_manage_others: false, email: 'test31@example.com')
        described_class.create!(can_manage_others: true, email: 'test32@example.com')
        described_class.create!(can_manage_others: true, deactivated_at: Time.zone.now, email: 'test33@example.com')
        user.deactivate!

        expect(user.deactivated?).to be false
      end
    end
  end

  describe '#email' do
    let(:email) { 'Jo.Example@example.com' }
    let(:user) { described_class.create!(email:) }

    before { user }

    it 'preserves the case it was created with' do
      expect(user.email).to eq email
    end

    it 'is case insensitive when queried' do
      query_email = email.dup.downcase
      expect(described_class.find_by(email: query_email).email).to eq email
    end

    it 'has case insensitive uniqueness enforced by the db' do
      invalid_user = described_class.new(email: email.downcase)
      expect { invalid_user.save(validate: false) }.to(
        raise_error(ActiveRecord::RecordNotUnique,
                    /Key \(email\)=\(jo.example@example.com\) already exists/)
      )
    end

    it 'validates uniqueness' do
      invalid_user = described_class.new(email: email.downcase)
      expect { invalid_user.save! }.to(
        raise_error(ActiveRecord::RecordInvalid)
      )
    end
  end

  describe '#invitation_expires_at' do
    it 'is set to 48 hours from now on create' do
      expect(invited_user.invitation_expires_at).to(
        be_within(1.second).of(48.hours.from_now)
      )
    end
  end

  describe '.pending_activation' do
    subject(:pending_activation) { described_class.pending_activation }

    let(:user) { invited_user }

    it 'returns an array of invited users pending activation' do
      expect(pending_activation).to include(user)
    end

    it 'excludes activated users' do
      user.update(auth_subject_id: SecureRandom.uuid)
      expect(pending_activation).not_to include(user)
    end
  end

  describe '.active' do
    subject(:active) { described_class.active }

    let(:user) { invited_user }

    it 'excludes users pending activation' do
      expect(active).not_to include(user)
    end

    it 'includes activated users' do
      user.update(auth_subject_id: SecureRandom.uuid)
      expect(active).to include(user)
    end

    it 'excludes deactivated users' do
      user.deactivate!
      expect(active).not_to include(user)
    end
  end

  describe '#auth_subject_id' do
    let(:auth_subject_id) { user.auth_subject_id }
    let(:user) { activated_user }

    before { user }

    it 'has uniqueness enforced by the db' do
      expect { described_class.create!(auth_subject_id: auth_subject_id, email: 'test@eg.com') }.to(
        raise_error(
          ActiveRecord::RecordNotUnique,
          /Key \(auth_subject_id\)=\(#{auth_subject_id}\) already exists./
        )
      )
    end
  end

  describe '#destroy' do
    context 'with a user pending_activation' do
      before { invited_user }

      it 'deletes the record' do
        expect { invited_user.destroy }.to change { described_class.count }.by(-1)
      end
    end

    context 'with an activated user' do
      it 'raises an error if user is acticated' do
        expect { activated_user.destroy }.to raise_error(User::CannotDestroyIfActive)
      end

      it 'does not delete the record' do
        expect { invited_user.destroy }.not_to(change { described_class.count })
      end
    end
  end

  describe '#renew_invitation!' do
    context 'with an expired invitation' do
      before { invited_user.update(invitation_expires_at: 1.hour.ago) }

      it 'updates the #invitation_expires_at' do
        expect { invited_user.renew_invitation! }.to(
          change { invited_user.invitation_expired? }.from(true).to(false)
        )

        expect(invited_user.invitation_expires_at).to(
          be_within(1.second).of(48.hours.from_now)
        )
      end
    end

    context 'with an activated user' do
      it 'raises an error if user is acticated' do
        expect { activated_user.renew_invitation! }.to(
          raise_error User::CannotRenewIfActive
        )
      end
    end
  end

  describe '.name_for(:id)' do
    subject(:name_for) { described_class.name_for(user_id) }

    let(:user_id) { SecureRandom.uuid }

    context 'when user not found' do
      it { is_expected.to eq '[deleted]' }
    end

    context 'when user is found' do
      before do
        described_class.create!(
          id: user_id,
          auth_oid: SecureRandom.uuid,
          auth_subject_id: SecureRandom.uuid,
          email: 'John.Deere@eg.com',
          first_name: 'John',
          last_name: 'Deere'
        )
      end

      it { is_expected.to eq 'John Deere' }
    end
  end
end

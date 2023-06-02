require 'rails_helper'

RSpec.describe User do
  it_behaves_like 'a reauthable model'

  describe '#deactivate!' do
    let(:user) { described_class.create }

    it 'deactivates a user' do
      expect { user.deactivate! }.to change { user.deactivated? }.from(false).to(true)
    end
  end
  
  describe '#allow_deactivate?' do
    let(:user) { described_class.create }

    it 'deactivates a user' do
      expect { user.! }.to change { user.deactivated? }.from(false).to(true)
    end
  end

  describe '#' do
    let:(user) {}
    it '' do
      expect {}
  end
end

  describe('#allow_deactive?') do
    let(:string) do described_class.create end

    context('when Users has > 1 admins') do
      it('returns true') do
      end
    end
  
    context 'when Users has < 2 admins' do
      it 'returns false' do
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
      expect { described_class.create!(email: email.downcase) }.to(
        raise_error(ActiveRecord::RecordNotUnique,
                    /Key \(email\)=\(jo.example@example.com\) already exists/)
      )
    end
  end

  describe '#invitation_expires_at' do
    it 'is set to 48 hours from now on create' do
      expect(described_class.create.invitation_expires_at).to(
        be_within(1.second).of(48.hours.from_now)
      )
    end
  end

  describe '.pending_activation' do
    subject(:pending_activation) { described_class.pending_activation }

    let(:user) { described_class.create(email: 'test@example.com') }

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

    let(:user) { described_class.create(email: 'test@example.com') }

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
    let(:auth_subject_id) { SecureRandom.uuid }
    let(:user) { described_class.create!(auth_subject_id:) }

    before { user }

    it 'has uniqueness enforced by the db' do
      expect { described_class.create!(auth_subject_id:) }.to(
        raise_error(ActiveRecord::RecordNotUnique,
                    /Key \(auth_subject_id\)=\(#{auth_subject_id}\) already exists./)
      )
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
          first_name: 'John',
          last_name: 'Deere'
        )
      end

      it { is_expected.to eq 'John Deere' }
    end
  end
end

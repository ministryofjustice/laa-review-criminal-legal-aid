require 'rails_helper'

RSpec.describe User do
  describe '#deactivate!' do
    let(:user) { described_class.create }

    it 'deactivates a user' do
      expect { user.deactivate! }.to change { user.deactivated? }.from(false).to(true)
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

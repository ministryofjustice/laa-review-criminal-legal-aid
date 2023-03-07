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

  describe '.authenticate!' do
    subject(:authenticate!) { described_class.authenticate!(auth_info) }

    let(:auth_info) do
      {
        'auth_oid' => SecureRandom.hex,
        'auth_subject_id' => SecureRandom.uuid,
        'email' => 'test@example.com',
        'first_name' => 'Jo',
        'last_name' => 'TEST'
      }
    end

    context 'when user does not exist in database' do
      it { is_expected.to be_nil }
    end

    context 'when an active user is found' do
      let(:user) { instance_double(described_class, update: true, deactivated?: false) }
      let(:expected_attributes) do
        {
          first_name: 'Jo',
          last_name: 'TEST',
          email: 'test@example.com',
          last_auth_at: Time.zone.now
        }
      end

      before do
        freeze_time
        allow(described_class).to receive(:find_by).with(
          { auth_subject_id: auth_info['auth_subject_id'] }
        ).and_return user
      end

      it 'returns the active user' do
        expect(authenticate!).to be user
      end

      it "sets the user's name, email and last_auth_at" do
        authenticate!
        expect(user).to have_received(:update).with expected_attributes
      end

      context 'when the user is deactivated' do
        let(:user) { instance_double(described_class, deactivated?: true) }

        it 'returns nil' do
          expect(authenticate!).to be_nil
        end
      end
    end
  end

  describe 'authenticate_and_activate!' do
    subject(:authenticate_and_activate!) do
      described_class.authenticate_and_activate!(auth_info)
    end

    let(:auth_info) do
      {
        'auth_oid' => SecureRandom.hex,
        'auth_subject_id' => SecureRandom.hex,
        'email' => 'test@example.com',
        'first_name' => 'Jo',
        'last_name' => 'TEST'
      }
    end

    context 'when a user pending activation does not exist in database' do
      it { is_expected.to be_nil }
    end

    context 'when a user pending activation exists in database' do
      let(:user) { instance_double(described_class, update: true, deactivated?: false) }

      let(:expected_attributes) do
        {
          first_name: 'Jo',
          last_name: 'TEST',
          auth_oid: auth_info.fetch('auth_oid'),
          auth_subject_id: auth_info.fetch('auth_subject_id'),
          first_auth_at: Time.zone.now,
          last_auth_at: Time.zone.now
        }
      end

      before do
        freeze_time

        allow(described_class).to receive(:find_pending_authentication_by_email)
          .with(auth_info['email'])
          .and_return user
      end

      it 'returns the active user' do
        expect(authenticate_and_activate!).to be user
      end

      it "sets the user's name, auth_oid, first_auth_at and last_auth_at" do
        authenticate_and_activate!
        expect(user).to have_received(:update).with(expected_attributes)
      end

      context 'when the user is deactivated' do
        let(:user) { instance_double(described_class, deactivated?: true) }

        it 'returns nil' do
          expect(authenticate_and_activate!).to be_nil
        end
      end
    end
  end
end

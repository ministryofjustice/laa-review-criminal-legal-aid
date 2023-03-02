require 'rails_helper'

RSpec.describe User do
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
        'email' => 'test@example.com',
        'first_name' => 'Jo',
        'last_name' => 'TEST'
      }
    end

    context 'when user does not exist in database' do
      it { is_expected.to be_nil }
    end

    context 'when a matching active user is found' do
      let(:user) { instance_double(described_class, update: true) }
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
          { auth_oid: auth_info['auth_oid'] }
        ).and_return user
      end

      it 'returns the active user' do
        expect(authenticate!).to be user
      end

      it "sets the user's name, email and last_auth_at" do
        authenticate!
        expect(user).to have_received(:update).with expected_attributes
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
        'email' => 'test@example.com',
        'first_name' => 'Jo',
        'last_name' => 'TEST'
      }
    end

    context 'when a user pending activation does not exist in database' do
      it { is_expected.to be_nil }
    end

    context 'when a user pending activation exists in database' do
      let(:user) { instance_double(described_class, update: true) }

      let(:expected_attributes) do
        {
          first_name: 'Jo',
          last_name: 'TEST',
          auth_oid: auth_info.fetch('auth_oid'),
          first_auth_at: Time.zone.now,
          last_auth_at: Time.zone.now
        }
      end

      before do
        freeze_time

        allow(described_class).to receive(:find_by)
          .with({ email: auth_info['email'], auth_oid: nil, first_auth_at: nil })
          .and_return user
      end

      it 'returns the active user' do
        expect(authenticate_and_activate!).to be user
      end

      it "sets the user's name, auth_oid, first_auth_at and last_auth_at" do
        authenticate_and_activate!
        expect(user).to have_received(:update).with(expected_attributes)
      end
    end
  end
end

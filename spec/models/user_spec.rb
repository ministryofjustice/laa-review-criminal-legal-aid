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
end

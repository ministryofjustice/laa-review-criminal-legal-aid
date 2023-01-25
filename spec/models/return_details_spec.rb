require 'rails_helper'

RSpec.describe ReturnDetails do
  subject(:new) { described_class.new(**params) }

  let(:params) { valid_attributes }
  let(:valid_attributes) { { reason: 'evidence_issue', details: 'Detailed reason' } }

  describe '#valid?' do
    subject(:valid?) { new.valid? }

    context 'with valid attributes' do
      it { is_expected.to be true }
    end

    context 'when return_reason type is not on the list' do
      let(:params) { { reason: 'not_a_return_reason', details: '' } }

      it { is_expected.to be false }
    end
  end

  describe '#errors' do
    subject(:errors) { new.errors }

    before do
      new.valid?
    end

    context 'with valid attributes' do
      it { is_expected.to be_empty }
    end

    context 'when return_reason type is not on the list' do
      let(:params) { { reason: 'not_a_return_reason', details: '' } }

      it { is_expected.not_to be_empty }

      it 'has an error message on type' do
        expect(errors[:reason]).to eq(['Choose a reason'])
      end
    end

    context 'when return_reason type is empty' do
      let(:params) { { details: '' } }

      it { is_expected.not_to be_empty }

      it 'has an error message on type' do
        expect(errors[:reason]).to eq(['Choose a reason'])
      end
    end
  end
end

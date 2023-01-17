require 'rails_helper'

RSpec.describe ReturnReason do
  subject(:new) { described_class.new(**params) }
  let(:params) { valid_attributes }
  let(:valid_attributes) {{ type: 'evidence_issue', details: "Detailed reason" }}

  describe '#valid?' do
    subject(:valid?) { new.valid? }

    context 'with valid attributes' do
      it { is_expected.to be true }
    end

    context 'when return_reason type is not on the list' do
      let(:params) {{ type: "not_a_return_reason", details: '' }}

      it { is_expected.to be false }
    end
  end

  describe '#errors' do
    before do
      new.valid?
    end

    subject(:errors) { new.errors }

    context 'with valid attributes' do
      it { is_expected.to be_empty }
    end

    context 'when return_reason type is not on the list' do
      let(:params) {{ type: "not_a_return_reason", details: '' }}

      it { is_expected.not_to be_empty }

      it 'has an error message on type' do
        expect(errors[:type]).to eq([
          "must be one of: clarification_required, evidence_issue, duplicate_application, case_concluded, provider_request"
        ])
      end
    end
    
    context 'when return_reason type is empty' do
      let(:params) {{ details: '' }}

      it { is_expected.not_to be_empty }

      it 'has an error message on type' do
        expect(errors[:type]).to eq([
          "is missing"
        ])
      end
    end
  end
end

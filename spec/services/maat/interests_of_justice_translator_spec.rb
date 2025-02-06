require 'rails_helper'

RSpec.describe Maat::InterestsOfJusticeTranslator do
  let(:maat_decision) do
    Maat::Decision.new(
      maat_ref: 6_000_001,
      ioj_reason: 'because',
      ioj_assessor_name: 'Ken',
      ioj_result: ioj_result,
      app_created_date: DateTime.new(2024, 12, 12, 12),
      ioj_appeal_result: ioj_appeal_result
    )
  end

  let(:ioj_appeal_result) { nil }

  describe '.translate' do
    subject(:translate) { described_class.translate(maat_decision:) }

    context 'when IoJ result is nil' do
      let(:ioj_result) { nil }

      it { is_expected.to be_nil }
    end

    context 'when IoJ result set' do
      let(:ioj_result) { 'FAIL' }

      it 'returns the translated result as a hash' do
        expect(translate).to eq LaaCrimeSchemas::Structs::TestResult.new(
          assessed_by: 'Ken',
          assessed_on: DateTime.new(2024, 12, 12, 12),
          details: 'because',
          result: 'failed'
        )
      end

      context 'when IoJ appeal result present' do
        let(:ioj_appeal_result) { 'PASS' }

        it 'uses the appeal result' do
          expect(translate).to eq LaaCrimeSchemas::Structs::TestResult.new(
            assessed_by: 'Ken',
            assessed_on: DateTime.new(2024, 12, 12, 12),
            details: 'because',
            result: 'passed'
          )
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Maat::MeansTranslator do
  let(:maat_decision) { Maat::Decision.new }

  describe '.translate' do
    subject(:translate) { described_class.translate(maat_decision:) }

    context 'when the means result and passport result are both nil' do
      let(:maat_decision) { Maat::Decision.new(maat_ref: 6_000_001) }

      it { is_expected.to be_nil }
    end

    context 'when only the passport result is present' do
      let(:maat_decision) do
        Maat::Decision.new(
          passport_assessor_name: 'Pam',
          passport_result: 'PASS',
          date_passport_created: DateTime.new(2024, 12, 12, 13)
        )
      end

      it 'returns the passporting result details' do
        expect(translate).to eq LaaCrimeSchemas::Structs::TestResult.new(
          assessed_by: 'Pam',
          assessed_on: DateTime.new(2024, 12, 12, 13),
          result: 'passed'
        )
      end
    end

    context 'when only the passport result is present and the result undetermined' do
      let(:maat_decision) do
        Maat::Decision.new(
          passport_assessor_name: 'Pam',
          passport_result: 'FAIL',
          date_passport_created: DateTime.new(2024, 12, 12, 13)
        )
      end

      it { is_expected.to be_nil }
    end

    context 'when only the means result is present' do
      let(:maat_decision) do
        Maat::Decision.new(
          means_assessor_name: 'Kit',
          means_result: 'FAIL',
          case_type: case_type,
          date_means_created: DateTime.new(2024, 12, 12, 12)
        )
      end

      let(:case_type) { 'SUMMARY_ONLY' }

      it 'returns the means result details' do
        expect(translate).to eq LaaCrimeSchemas::Structs::TestResult.new(
          assessed_by: 'Kit',
          assessed_on: DateTime.new(2024, 12, 12, 12),
          result: 'failed'
        )
      end

      context 'when a Crown Court decision' do
        let(:case_type) { 'INDICTABLE' }

        it 'returns the Crown Court court means result' do
          expect(translate).to eq LaaCrimeSchemas::Structs::TestResult.new(
            assessed_by: 'Kit',
            assessed_on: DateTime.new(2024, 12, 12, 12),
            result: 'passed_with_contribution'
          )
        end
      end
    end

    context 'when both means and passport results are present' do
      let(:maat_decision) do
        Maat::Decision.new(
          passport_assessor_name: 'Pam',
          passport_result: 'PASS',
          date_passport_created: DateTime.new(2024, 12, 12, 13),
          means_assessor_name: 'Kit',
          means_result: 'FAIL',
          date_means_created: DateTime.new(2024, 12, 12, 12)
        )
      end

      it 'uses the most recent' do
        expect(translate).to eq LaaCrimeSchemas::Structs::TestResult.new(
          assessed_by: 'Pam',
          assessed_on: DateTime.new(2024, 12, 12, 13),
          result: 'passed'
        )
      end
    end

    context 'when means and passport results have the same timestamp' do
      let(:maat_decision) do
        Maat::Decision.new(
          passport_assessor_name: 'Pam',
          passport_result: 'PASS',
          date_passport_created: DateTime.new(2024, 12, 12, 12),
          means_assessor_name: 'Kit',
          means_result: 'FAIL',
          date_means_created: DateTime.new(2024, 12, 12, 12)
        )
      end

      it 'returns the means result details' do
        expect(translate).to eq LaaCrimeSchemas::Structs::TestResult.new(
          assessed_by: 'Kit',
          assessed_on: DateTime.new(2024, 12, 12, 12),
          result: 'failed'
        )
      end
    end
  end
end

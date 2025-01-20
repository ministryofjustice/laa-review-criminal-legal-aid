require 'rails_helper'

RSpec.describe Maat::DecisionTranslator do
  let(:maat_decision) { Maat::Decision.new(funding_decision: nil) }

  let(:translated_means) do
    LaaCrimeSchemas::Structs::TestResult.new(
      result: 'passed',
      assessed_by: 'Ken',
      assessed_on: '2024-12-12'
    )
  end

  describe '.translate' do
    subject(:translate) { described_class.translate(maat_decision) }

    let(:maat_decision) { Maat::Decision.new }

    it { is_expected.to be_a Decisions::Draft }

    describe '#funding_decision' do
      subject(:funding_decision) { translate.funding_decision }

      before do
        allow(Maat::MeansTranslator).to receive(:translate) { translated_means }
      end

      context 'when not decided' do
        it { is_expected.to be_nil }
      end

      context 'when funding decision exists' do
        let(:maat_decision) do
          Maat::Decision.new(funding_decision: 'FAILIOJ')
        end

        it { is_expected.to eq 'refused' }
      end

      context 'when funding decision exists but means is empty' do
        let(:maat_decision) do
          Maat::Decision.new(funding_decision: 'FAILIOJ')
        end

        let(:translated_means) { nil }

        it { is_expected.to be_nil }
      end

      context 'when a crown court decision exists' do
        let(:maat_decision) do
          Maat::Decision.new(cc_rep_decision: 'Granted - Passported')
        end

        it { is_expected.to eq 'granted' }
      end

      context 'when both a crown court and funding decision exists' do
        let(:maat_decision) do
          Maat::Decision.new(
            funding_decision: 'FAILMEIOJ',
            cc_rep_decision: 'Granted - Passported'
          )
        end

        it 'returns the crown court decision' do
          expect(funding_decision).to eq 'granted'
        end
      end
    end

    describe '#case_id' do
      subject(:case_id) { translate.case_id }

      context 'when case_id nil' do
        it { is_expected.to be_nil }
      end

      context 'when case_id is set' do
        let(:maat_decision) { Maat::Decision.new(case_id: 'AbD123') }

        it { is_expected.to eq 'AbD123' }
      end
    end

    describe '#maat_id' do
      subject(:maat_id) { translate.maat_id }

      context 'when maat_ref nil' do
        it { is_expected.to be_nil }
      end

      context 'when maat_ref is set' do
        let(:maat_decision) { Maat::Decision.new(maat_ref: 6_090_910) }

        it { is_expected.to be 6_090_910 }
      end
    end

    describe '#decision_id' do
      subject(:decision_id) { translate.decision_id }

      context 'when maat_ref nil' do
        it { is_expected.to be_nil }
      end

      context 'when maat_ref is set' do
        let(:maat_decision) { Maat::Decision.new(maat_ref: 6_090_910) }

        it { is_expected.to be 6_090_910 }
      end
    end

    describe '#reference' do
      subject(:reference) { translate.reference }

      context 'when usn nil' do
        it { is_expected.to be_nil }
      end

      context 'when usn is set' do
        let(:maat_decision) { Maat::Decision.new(usn: 6_090_910) }

        it { is_expected.to be 6_090_910 }
      end
    end

    describe '#means' do
      subject(:means) { translate.means }

      before do
        allow(Maat::MeansTranslator).to receive(:translate)
          .with(maat_decision, court_type: nil) { translated_means }
      end

      it { is_expected.to be translated_means }
    end

    describe '#interests_of_justice' do
      subject(:interests_of_justice) { translate.interests_of_justice }

      let(:translated_interests_of_justice) do
        LaaCrimeSchemas::Structs::TestResult.new(
          result: 'failed',
          assessed_by: 'Jo',
          assessed_on: '2024-12-11'
        )
      end

      before do
        allow(Maat::InterestsOfJusticeTranslator).to receive(:translate)
          .with(maat_decision) { translated_interests_of_justice }
      end

      it { is_expected.to be translated_interests_of_justice }
    end

    describe '#court_type' do
      subject(:court_type) { translate.court_type }

      context 'when not decided' do
        it { is_expected.to be_nil }
      end

      context 'when funding decision exists' do
        let(:maat_decision) { Maat::Decision.new(funding_decision: 'FAILIOJ') }

        it { is_expected.to eq Types::CourtType['magistrates'] }
      end

      context 'when a crown court decision exists' do
        let(:maat_decision) { Maat::Decision.new(cc_rep_decision: 'Granted - Passported') }

        it { is_expected.to eq Types::CourtType['crown'] }
      end
    end
  end
end

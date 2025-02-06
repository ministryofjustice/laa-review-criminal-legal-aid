require 'rails_helper'

RSpec.describe Deciding::OverallResultCalculator do
  describe '#calculate' do
    subject do
      described_class.new(decision).calculate
    end

    let(:decision) do
      instance_double(
        LaaCrimeSchemas::Structs::Decision,
        means: instance_double(
          LaaCrimeSchemas::Structs::TestResult, result: means_result
        ),
        assessment_rules: assessment_rules,
        funding_decision: funding_decision,
        interests_of_justice: instance_double(
          LaaCrimeSchemas::Structs::TestResult, result: ioj_result
        )
      )
    end

    context 'when funding is granted' do
      let(:funding_decision) { 'granted' }
      let(:assessment_rules) { 'magistrates_court' }

      context 'when means test is failed' do
        let(:ioj_result) { 'passed' }
        let(:means_result) { 'failed' }

        it { is_expected.to eq('granted_failed_means') }
      end

      context 'when means test passed with contribution' do
        let(:ioj_result) { 'passed' }
        let(:means_result) { 'passed_with_contribution' }

        it { is_expected.to eq('granted_with_contribution') }
      end

      context 'when means test fully passed' do
        let(:ioj_result) { 'passed' }
        let(:means_result) { 'passed' }

        it { is_expected.to eq('granted') }
      end
    end

    context 'when funding is refused and `assessment_rules` "crown_court"' do
      let(:ioj_result) { 'passed' }
      let(:funding_decision) { 'refused' }
      let(:assessment_rules) { 'crown_court' }

      context 'when the means test failed' do
        let(:means_result) { 'failed' }

        it { is_expected.to eq('refused_ineligible') }
      end

      context 'when both tests pass' do
        let(:ioj_result) { 'passed' }
        let(:means_result) { 'passed' }

        it { is_expected.to eq('refused') }
      end
    end
  end
end

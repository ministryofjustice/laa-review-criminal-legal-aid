require 'rails_helper'

RSpec.describe DecisionOverallResultComponent, type: :component do
  describe '.new' do
    subject(:tag) { page }

    let(:decision) { instance_double Decisions::Draft, means:, funding_decision: }
    let(:funding_decision) { nil }
    let(:means) { nil }

    before do
      render_inline(described_class.new(decision:))
    end

    context 'when funding decision is "granted"' do
      let(:funding_decision) { 'granted' }

      it { is_expected.to have_text('Granted') }
      it { is_expected.to have_css('.govuk-tag--green') }

      context 'when with contribution' do
        let(:means) do
          instance_double(LaaCrimeSchemas::Structs::TestResult, result: 'passed_with_contribution')
        end

        it { is_expected.to have_text('Granted - with a contribution') }
        it { is_expected.to have_css('.govuk-tag--green') }
      end

      context 'when failed means' do
        let(:means) do
          instance_double(LaaCrimeSchemas::Structs::TestResult, result: 'failed')
        end

        it { is_expected.to have_text('Granted - failed means test') }
        it { is_expected.to have_css('.govuk-tag--green') }
      end
    end

    context 'when funding decision is "refuse"' do
      let(:funding_decision) { 'refused' }

      it { is_expected.to have_text('Refused') }
      it { is_expected.to have_css('.govuk-tag--red') }

      context 'when failed means' do
        let(:means) do
          instance_double(LaaCrimeSchemas::Structs::TestResult, result: 'failed')
        end

        it { is_expected.to have_text('Refused') }
        it { is_expected.to have_css('.govuk-tag--red') }
      end
    end
  end
end

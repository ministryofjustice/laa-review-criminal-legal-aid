require 'rails_helper'

RSpec.describe DecisionOverallResultComponent, type: :component do
  describe '.new' do
    subject(:tag) { page }

    let(:decision) { instance_double Decisions::Draft, overall_result:, funding_decision: }
    let(:funding_decision) { nil }
    let(:overall_result) { nil }

    before do
      render_inline(described_class.new(decision:))
    end

    context 'when funding is "granted"' do
      let(:funding_decision) { 'granted' }
      let(:overall_result) { 'Granted - Passed Means Test' }

      it { is_expected.to have_text('Granted') }
      it { is_expected.to have_css('.govuk-tag--green') }
    end

    context 'when funding is "refused"' do
      let(:funding_decision) { 'refused' }
      let(:overall_result) { 'Refused - Ineligible' }

      it { is_expected.to have_text('Refused - Ineligible') }
      it { is_expected.to have_css('.govuk-tag--red') }
    end

    context 'when overall_result is nil' do
      let(:funding_decision) { 'refused' }
      let(:overall_result) { nil }

      it { is_expected.to have_text('') }
      it { is_expected.not_to have_css('.govuk-tag') }
    end
  end
end

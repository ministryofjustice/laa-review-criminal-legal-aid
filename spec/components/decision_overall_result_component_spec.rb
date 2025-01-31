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
      let(:overall_result) { Types::OverallResult['granted_with_contribution'] }

      it { is_expected.to have_text('Granted') }
      it { is_expected.to have_css('.govuk-tag--green') }
    end

    context 'when funding is "refused"' do
      let(:funding_decision) { 'refused' }
      let(:overall_result) { 'refused' }

      it { is_expected.to have_text('Refused') }
      it { is_expected.to have_css('.govuk-tag--red') }
    end

    context 'when overall_result is nil' do
      let(:funding_decision) { 'refused' }
      let(:overall_result) { nil }

      it { is_expected.to have_text('') }
      it { is_expected.not_to have_css('.govuk-tag') }
    end

    describe 'overall result text' do
      [
        'granted', 'Granted',
        'granted_with_contribution', 'Granted - with contribution',
        'granted_failed_means', 'Granted - failed means',
        'refused', 'Refused',
        'refused_failed_ioj', 'Refused - failed IoJ',
        'refused_failed_ioj_and_means', 'Refused - failed IoJ & means',
        'refused_failed_means', 'Refused - failed means'
      ].each_slice(2).each do |type, text|
        it "translates #{type} to #{text}" do
          expect(I18n.t(type, scope: [:values, :decision_overall_result])).to eq(text)
        end
      end
    end
  end
end

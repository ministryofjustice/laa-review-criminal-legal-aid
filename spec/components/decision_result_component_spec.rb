require 'rails_helper'

RSpec.describe DecisionResultComponent, type: :component do
  describe '.new' do
    subject(:tag) { page }

    before do
      render_inline(described_class.new(result:))
    end

    context 'when result is "granted"' do
      let(:result) { 'granted' }

      it { is_expected.to have_text('Granted') }
      it { is_expected.to have_css('.govuk-tag--green') }
    end

    context 'when result is "granted_on_ioj"' do
      let(:result) { 'granted_on_ioj' }

      it { is_expected.to have_text('Granted') }
      it { is_expected.to have_css('.govuk-tag--green') }
    end

    context 'when result is "failed_on_ioj"' do
      let(:result) { 'fail_on_ioj' }

      it { is_expected.to have_text('Failed IoJ') }
      it { is_expected.to have_css('.govuk-tag--red') }
    end

    context 'when result is "failioj"' do
      let(:result) { 'failioj' }

      it { is_expected.to have_text('Failed IoJ') }
      it { is_expected.to have_css('.govuk-tag--red') }
    end

    context 'when result is "inel"' do
      let(:result) { 'inel' }

      it { is_expected.to have_text('Ineligible') }
      it { is_expected.to have_css('.govuk-tag--red') }
    end

    context 'when result is "failmeans"' do
      let(:result) { 'failmeans' }

      it { is_expected.to have_text('Failed means') }
      it { is_expected.to have_css('.govuk-tag--red') }
    end
  end
end

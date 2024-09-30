require 'rails_helper'

RSpec.describe DecisionResultComponent, type: :component do
  describe '.new' do
    subject(:tag) { page }

    before do
      render_inline(described_class.new(result:))
    end

    context 'when result is "pass"' do
      let(:result) { 'pass' }

      it { is_expected.to have_text('Passed') }
      it { is_expected.to have_css('.govuk-tag--green') }
    end

    context 'when result is "granted_on_ioj"' do
      let(:result) { 'granted_on_ioj' }

      it { is_expected.to have_text('Granted') }
      it { is_expected.to have_css('.govuk-tag--green') }
    end

    context 'when result is "failed_on_ioj"' do
      let(:result) { 'fail_on_ioj' }

      it { is_expected.to have_text('Rejected') }
      it { is_expected.to have_css('.govuk-tag--red') }
    end

    context 'when result is "fail"' do
      let(:result) { 'fail' }

      it { is_expected.to have_text('Fail') }
      it { is_expected.to have_css('.govuk-tag--red') }
    end
  end
end

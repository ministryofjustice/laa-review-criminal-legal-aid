require 'rails_helper'

RSpec.describe DecisionResultComponent, type: :component do
  describe '.new' do
    subject(:tag) { page }

    before do
      render_inline(described_class.new(result:))
    end

    context 'when decision is "grant"' do
      let(:result) { 'granted' }

      it { is_expected.to have_text('Granted') }
      it { is_expected.to have_css('.govuk-tag--green') }
    end

    context 'when decision is "refuse"' do
      let(:result) { 'refused' }

      it { is_expected.to have_text('Refused') }
      it { is_expected.to have_css('.govuk-tag--red') }
    end
  end
end

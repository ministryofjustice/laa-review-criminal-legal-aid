require 'rails_helper'

RSpec.describe DecisionComponent, type: :component do
  let(:decision) { double }

  before do
    allow(decision).to receive_messages(
      interests_of_justice: {},
      means: {},
      funding_decision: 'granted',
      comment: nil,
      maat_id: nil
    )
  end

  describe '.new' do
    before { render_inline(described_class.new(decision:)) }

    describe 'card title' do
      subject { page.first('h2.govuk-summary-card__title').text }

      it { is_expected.to eq('Case') }
    end
  end

  describe '.with_collection' do
    before { render_inline described_class.with_collection(decisions) }

    describe 'card titles' do
      subject(:titles) { page.all('h2.govuk-summary-card__title').map(&:text) }

      context 'when there is only one card' do
        let(:decisions) { [decision] }

        it { is_expected.to eq(['Case']) }
      end

      context 'when there are multiple cards' do
        let(:decisions) { [decision, decision, decision] }

        it { is_expected.to eq(['Case 1', 'Case 2', 'Case 3']) }
      end
    end
  end
end

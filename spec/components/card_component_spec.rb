require 'rails_helper'

RSpec.describe CardComponent, type: :component do
  describe '.new' do
    before do
      render_inline(described_class.new(item: double, title: 'My item'))
    end

    describe 'card title' do
      subject { page.first('h2.govuk-summary-card__title').text }

      it { is_expected.to eq('My item') }
    end
  end

  describe '.with_collection' do
    before do
      render_inline described_class.with_collection(items, title: 'My item')
    end

    describe 'card titles' do
      subject { page.all('h2.govuk-summary-card__title').map(&:text) }

      context 'when there is only one item' do
        let(:items) { [double] }

        it { is_expected.to eq(['My item']) }
      end

      context 'when there are multiple item' do
        let(:items) { [double, double, double] }

        it { is_expected.to eq(['My item 1', 'My item 2', 'My item 3']) }
      end
    end
  end
end

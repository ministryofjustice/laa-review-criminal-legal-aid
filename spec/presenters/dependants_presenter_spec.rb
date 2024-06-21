require 'rails_helper'

RSpec.describe DependantsPresenter do
  subject(:dependants_presenter) { described_class.new(dependants) }

  let(:dependants) do
    [{ age: 1 }, { age: 5 }, { age: 12 }, { age: 15 }, { age: 4 }, { age: 7 }, { age: 8 }, { age: 17 }]
  end

  describe '#formatted_dependants' do
    subject(:formatted_dependants) { dependants_presenter.formatted_dependants }

    it {
      expect(formatted_dependants).to eq({ '2 to 4' => 1,
                                           '5 to 7' => 2,
                                           '8 to 10' => 2,
                                           '13 to 15' => 1,
                                           '16 to 18' => 2 })
    }

    context 'with no dependants' do
      let(:dependants) { nil }

      it { expect(formatted_dependants).to be_nil }
    end
  end
end

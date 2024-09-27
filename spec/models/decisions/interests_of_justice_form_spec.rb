require 'rails_helper'

RSpec.describe Decisions::InterestsOfJusticeForm do
  subject(:form_object) { described_class.new }

  describe '#possible_results' do
    subject(:possible_results) { form_object.possible_results }

    it { is_expected.to eq %w[pass fail] }
  end

  describe '#command_class' do
    it 'returns Deciding::SetComment' do
      expect(form_object.send(:command_class)).to eq Deciding::SetInterestsOfJustice
    end
  end
end

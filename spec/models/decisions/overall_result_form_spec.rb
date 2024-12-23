require 'rails_helper'

RSpec.describe Decisions::OverallResultForm do
  subject(:form_object) { described_class.new }

  describe '#possible_decisions' do
    subject(:possible_decisions) { form_object.possible_decisions }

    it { is_expected.to eq %w[granted refused] }
  end

  describe '#command_class' do
    it 'returns Deciding::SetComment' do
      expect(form_object.send(:command_class)).to eq Deciding::SetFundingDecision
    end
  end
end

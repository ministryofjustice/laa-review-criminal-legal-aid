require 'rails_helper'

describe Deciding::Decision do
  subject(:decision) { described_class.new(SecureRandom.uuid) }

  describe '#attributes' do
    let(:interests_of_justice) do
      Types::InterestsOfJusticeDecision.call(result: 'pass', details: 'details', assessed_by: 'Grace Nolan',
                                             assessed_on: Date.new(2024, 10, 1))
    end
    let(:funding_decision) { 'granted' }
    let(:comment) { 'Caseworker comment' }

    before do
      decision.set_interests_of_justice(user_id: SecureRandom.uuid, interests_of_justice: interests_of_justice)
      decision.set_funding_decision(user_id: SecureRandom.uuid, funding_decision: funding_decision)
      decision.set_comment(user_id: SecureRandom.uuid, comment: comment)
    end

    it 'returns the expected attributes' do # rubocop:disable RSpec/MultipleExpectations
      expect(decision.attributes[:interests_of_justice]).to eq(interests_of_justice)
      expect(decision.attributes[:funding_decision]).to eq(funding_decision)
      expect(decision.attributes[:comment]).to eq(comment)
    end
  end
end

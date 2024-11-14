require 'rails_helper'

describe Deciding::Decision do
  subject(:decision) { described_class.new(SecureRandom.uuid) }

  describe '#attributes' do
    let(:interests_of_justice) do
      LaaCrimeSchemas::Structs::TestResult.new(
        result: 'pass',
        details: 'details',
        assessed_by: 'Grace Nolan',
        assessed_on: Date.new(2024, 10, 1)
      )
    end

    let(:funding_decision) { 'granted' }
    let(:comment) { 'Caseworker comment' }

    before do
      decision.set_interests_of_justice(user_id: SecureRandom.uuid, interests_of_justice: interests_of_justice)
      decision.set_funding_decision(user_id: SecureRandom.uuid, funding_decision: funding_decision)
      decision.set_comment(user_id: SecureRandom.uuid, comment: comment)
    end

    it 'returns the expected attributes' do # rubocop:disable RSpec/MultipleExpectations
      expect(decision.interests_of_justice).to eq(interests_of_justice)
      expect(decision.funding_decision).to eq(funding_decision)
      expect(decision.comment).to eq(comment)
    end
  end

  describe '#complete?' do
    context 'when funding_decision is present' do
      let(:funding_decision) { 'granted' }

      before do
        decision.set_funding_decision(user_id: SecureRandom.uuid, funding_decision: funding_decision)
      end

      it 'returns true' do
        expect(decision.complete?).to be(true)
      end
    end

    context 'when funding_decision is not present' do
      let(:funding_decision) { nil }

      it 'returns false' do
        expect(decision.complete?).to be(false)
      end
    end
  end
end

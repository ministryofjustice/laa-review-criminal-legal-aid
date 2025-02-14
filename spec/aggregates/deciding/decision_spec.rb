require 'rails_helper'

describe Deciding::Decision do
  subject(:decision) { described_class.new(SecureRandom.uuid) }

  let(:funding_decision) { 'granted' }
  let(:comment) { 'Caseworker comment' }
  let(:user_id) { SecureRandom.uuid }
  let(:application_id) { SecureRandom.uuid }

  describe '#attributes' do
    let(:interests_of_justice) do
      LaaCrimeSchemas::Structs::TestResult.new(
        result: 'passed',
        details: 'details',
        assessed_by: 'Grace Nolan',
        assessed_on: Date.new(2024, 10, 1)
      )
    end

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

  describe '#link' do
    subject(:link) { decision.link(application_id:, user_id:, reference:) }

    let(:maat_decision) do
      { reference: 100_123, maat_id: 60_001 }
    end

    before do
      decision.create_draft_from_maat(maat_decision:, user_id:)
    end

    context 'when reference missmatch' do
      let(:reference) { 123_123 }

      it { expect { link }.to raise_error Deciding::ReferenceMismatch }
    end

    context 'when reference matches' do
      let(:reference) { 100_123 }

      it { expect { link }.not_to raise_error }
    end

    context 'when already link' do
      let(:reference) { 100_123 }

      before { decision.link(application_id:, user_id:, reference:) }

      it { expect { link }.to raise_error Deciding::AlreadyLinked }
    end
  end

  describe '#link_to_cifc' do
    subject(:link) { decision.link_to_cifc(application_id:, user_id:) }

    let(:maat_decision) do
      { reference: 100_123, maat_id: 60_001, funding_decision: 'refused' }
    end

    before do
      decision.create_draft_from_maat(maat_decision:, user_id:)
    end

    context 'when reference missmatch' do
      let(:reference) { 123_123 }

      it { expect { link }.not_to raise_error }
    end

    context 'when already link and in draft' do
      let(:reference) { 100_123 }

      before { decision.link(application_id:, user_id:, reference:) }

      it { expect { link }.to raise_error Deciding::AlreadyLinked }
    end

    context 'when already link but sent to provider' do
      let(:reference) { 100_123 }

      before do
        decision.link(application_id:, user_id:, reference:)
        decision.send_to_provider(application_id:, user_id:)
      end

      it { expect { link }.not_to raise_error }
    end
  end

  describe '#link_to_nafi' do
    subject(:link) { decision.link_to_nafi(application_id:, user_id:) }

    let(:maat_decision) do
      { reference: 100_123, maat_id: 60_001, funding_decision: 'refused' }
    end

    before do
      decision.create_draft_from_maat(maat_decision:, user_id:)
    end

    context 'when reference missmatch' do
      let(:reference) { 123_123 }

      it { expect { link }.not_to raise_error }
    end

    context 'when already link and in draft' do
      let(:reference) { 100_123 }

      before { decision.link(application_id:, user_id:, reference:) }

      it { expect { link }.to raise_error Deciding::AlreadyLinked }
    end

    context 'when already link but sent to provider' do
      let(:reference) { 100_123 }

      before do
        decision.link(application_id:, user_id:, reference:)
        decision.send_to_provider(application_id:, user_id:)
      end

      it { expect { link }.not_to raise_error }
    end
  end

  describe '#send_to_provider' do
    subject(:send_to_provider) { decision.send_to_provider(application_id:, user_id:) }

    let(:maat_decision) do
      { reference: 100_123, maat_id: 60_001, funding_decision: 'refused' }
    end

    before do
      decision.create_draft_from_maat(maat_decision:, user_id:)
    end

    context 'when not linked' do
      it { expect { send_to_provider }.to raise_error Deciding::NotLinked }
    end

    context 'when linked' do
      before do
        decision.link_to_nafi(application_id:, user_id:)
      end

      it { expect { send_to_provider }.not_to raise_error }
    end

    context 'when already sent' do
      before do
        decision.link_to_nafi(application_id:, user_id:)
        decision.send_to_provider(application_id:, user_id:)
      end

      it { expect { send_to_provider }.to raise_error Deciding::AlreadySent }
    end

    context 'when not complete' do
      let(:maat_decision) { super().merge(funding_decision: nil) }

      before do
        decision.link_to_nafi(application_id:, user_id:)
      end

      it { expect { send_to_provider }.to raise_error Deciding::IncompleteDecision }
    end
  end
end

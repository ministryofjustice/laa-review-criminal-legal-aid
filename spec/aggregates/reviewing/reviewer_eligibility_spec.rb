require 'rails_helper'

RSpec.describe Reviewing::ReviewerEligibility do
  subject(:eligibility) { described_class.new(user:, review:) }

  include_context 'with an existing caseworker user'
  include_context 'with an existing supervisor user'

  let(:review) { instance_double(Reviewing::Review) }

  context 'when the user is a caseworker' do
    let(:user) { caseworker_user }

    it 'allows the user to review' do
      expect(eligibility.allowed?).to be(true)
    end
  end

  context 'when the user is not a caseworker' do
    let(:user) { supervisor_user }

    it 'does not allow the user to review' do
      expect(eligibility.allowed?).to be(false)
    end
  end
end

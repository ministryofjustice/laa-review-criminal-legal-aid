require 'rails_helper'

RSpec.describe Reviewing::ReviewerEligibility do
  subject(:eligibility) { described_class.new(user:, review:) }

  include_context 'with an existing caseworker user'
  include_context 'with an existing supervisor user'

  let(:review) { instance_double(Reviewing::Review) }
  let(:data_analyst_user) do
    User.create!(
      first_name: 'Data',
      last_name: 'Analyst',
      email: "data-analyst-#{SecureRandom.hex(4)}@example.com",
      auth_subject_id: SecureRandom.uuid,
      can_manage_others: false,
      role: UserRole::DATA_ANALYST
    )
  end
  let(:auditor_user) do
    User.create!(
      first_name: 'Audit',
      last_name: 'User',
      email: "auditor-#{SecureRandom.hex(4)}@example.com",
      auth_subject_id: SecureRandom.uuid,
      can_manage_others: false,
      role: UserRole::AUDITOR
    )
  end

  context 'when the user is a caseworker' do
    let(:user) { caseworker_user }

    it 'allows the user to review' do
      expect(eligibility.allowed?).to be(true)
    end
  end

  context 'when the user is a supervisor' do
    let(:user) { supervisor_user }

    it 'does not allow the user to review' do
      expect(eligibility.allowed?).to be(false)
    end
  end

  context 'when the user is a data analyst' do
    let(:user) { data_analyst_user }

    it 'does not allow the user to review' do
      expect(eligibility.allowed?).to be(false)
    end
  end

  context 'when the user is an auditor' do
    let(:user) { auditor_user }

    it 'does not allow the user to review' do
      expect(eligibility.allowed?).to be(false)
    end
  end
end

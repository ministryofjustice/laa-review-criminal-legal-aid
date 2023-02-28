require 'rails_helper'

RSpec.describe CrimeApplication do
  subject(:application) { described_class.new(attributes) }

  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:review) { instance_double(Reviewing::Review, received?: true, state: :open) }
  let(:assignment) { instance_double(Assigning::Assignment) }

  describe '#applicant_date_of_birth' do
    subject(:applicant_date_of_birth) { application.applicant_date_of_birth }

    it { is_expected.to eq Date.parse('2011-06-09') }
  end

  describe '#applicant_name' do
    subject(:applicant_name) { application.applicant_name }

    it { is_expected.to eq 'Kit Pound' }
  end

  describe '#assignee_name' do
    subject(:assignee_name) { application.assignee_name }

    it { is_expected.to be_nil }

    context 'when assigned' do
      before do
        user_id = SecureRandom.uuid
        allow(Assigning::LoadAssignment).to receive(:call) { assignment }
        allow(assignment).to receive(:assignee_id) { user_id }
        allow(User).to receive(:name_for).with(user_id).and_return('John Deere')
      end

      it { is_expected.to eq('John Deere') }
    end
  end

  describe '#history' do
    subject(:history) { application.history }

    it { is_expected.to be_a ApplicationHistory }
  end

  describe '#all_histories' do
    subject(:history) { application.all_histories }

    context 'when initital submission' do
      it { is_expected.to eq [application.history] }
    end
  end

  describe '#parent' do
    subject(:parent) { application.parent }

    context 'when an initital submission' do
      it { is_expected.to be_nil }
    end

    context 'when a re-submission' do
      let(:parent_id) { SecureRandom.uuid }
      let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge({ 'parent_id' => parent_id }) }
      let(:parent) { instance_double(described_class) }

      before do
        allow(described_class).to receive(:find).with(parent_id) { parent }
      end

      it { is_expected.to be parent }
    end

    context 'when parent id is same as the id' do
      let(:attributes) do
        JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge(
          { 'parent_id' => '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
        )
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#legal_rep_name' do
    subject(:legal_rep_name) { application.legal_rep_name }

    it { is_expected.to eq 'John Doe' }
  end

  describe '#means_type' do
    subject(:means_type) { application.means_type }

    it { is_expected.to eq :passported }
  end

  describe '#reviewable_by?' do
    subject(:reviewable_by?) { application.reviewable_by?(user_id) }

    let(:user_id) { SecureRandom.uuid }

    context 'when not assigned to the user' do
      it { is_expected.to be false }
    end

    context 'when assigned to the user' do
      before do
        allow(Assigning::LoadAssignment).to receive(:call) { assignment }
        allow(assignment).to receive(:assigned_to?).with(user_id).and_return(true)
      end

      it { is_expected.to be true }

      context 'when already reviewed' do
        before do
          allow(Reviewing::LoadReview).to receive(:call) { review }
          allow(review).to receive(:reviewed?).and_return(true)
        end

        it { is_expected.to be false }
      end
    end
  end

  describe '#review_status' do
    subject(:review_status) { application.review_status }

    before do
      allow(Reviewing::LoadReview).to receive(:call) { review }
      allow(review).to receive(:state).and_return(:open)
    end

    it { is_expected.to be(:open) }
  end

  describe '#reviewed_at' do
    subject(:reviewed_at) { application.reviewed_at }

    before do
      allow(Reviewing::LoadReview).to receive(:call) { review }
      allow(review).to receive(:reviewed_at).and_return('2023-01-01')
    end

    it { is_expected.to eq '2023-01-01' }
  end

  describe '#reviewer_name' do
    subject(:reviewed_status) { application.reviewer_name }

    it { is_expected.to be_nil }

    context 'when reviewed' do
      before do
        user_id = SecureRandom.uuid
        allow(Reviewing::LoadReview).to receive(:call) { review }
        allow(review).to receive(:reviewer_id) { user_id }
        allow(User).to receive(:name_for).with(user_id).and_return('David Brown')
      end

      it { is_expected.to eq('David Brown') }
    end
  end

  describe '#unassigned?' do
    subject(:unassigned?) { application.unassigned? }

    it { is_expected.to be(true) }
  end
end

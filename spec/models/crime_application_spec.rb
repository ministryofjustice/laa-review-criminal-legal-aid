require 'rails_helper'

RSpec.describe CrimeApplication do
  subject(:application) { described_class.new(attributes) }

  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:review) { instance_double(Reviewing::Review, received?: true, state: :open) }
  let(:assignment) { instance_double(Assigning::Assignment) }

  describe '#applicant_date_of_birth' do
    subject(:applicant_date_of_birth) { application.applicant_date_of_birth }

    it { is_expected.to eq Date.parse('2001-06-09') }
  end

  describe '#applicant_name' do
    subject(:applicant_name) { application.applicant_name }

    it { is_expected.to eq 'Kit Pound' }
  end

  describe '#formatted_applicant_nino' do
    subject(:formatted_applicant_nino) { application.formatted_applicant_nino }

    it { is_expected.to eq 'AJ123456C' }
  end

  describe '#formatted_applicant_telephone_number' do
    subject(:formatted_applicant_telephone_number) { application.formatted_applicant_telephone_number }

    it { is_expected.to eq '07771 231 231' }

    context 'with input that has +44 and no 0' do
      before do
        attributes['client_details']['applicant']['telephone_number'] = '+447123123123'
      end

      it { is_expected.to eq '+44 7123 123 123' }
    end

    context 'with input that has +44 and 0' do
      before do
        attributes['client_details']['applicant']['telephone_number'] = '+4407123456456'
      end

      it { is_expected.to eq '+44 07123 456 456' }
    end

    context 'with input that has +44 and 0 with parentheses' do
      before do
        attributes['client_details']['applicant']['telephone_number'] = '+44(0)7123789789'
      end

      it { is_expected.to eq '+44 (0) 7123 789 789' }
    end
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
      let(:attributes) { super().merge({ 'parent_id' => parent_id }) }
      let(:parent) { instance_double(described_class) }

      before do
        allow(described_class).to receive(:find).with(parent_id) { parent }
      end

      it { is_expected.to be parent }
    end

    context 'when parent id is same as the id' do
      let(:attributes) do
        super().merge({ 'parent_id' => '696dd4fd-b619-4637-ab42-a5f4565bcf4a' })
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#legal_rep_name' do
    subject(:legal_rep_name) { application.legal_rep_name }

    it { is_expected.to eq 'John Doe' }
  end

  describe '#means_passported?' do
    subject(:means_passported?) { application.means_passported? }

    let(:attributes) { super().merge({ 'means_passport' => means_passport }) }

    context 'when application is means passported on DWP' do
      let(:means_passport) { [Types::MeansPassportType['on_benefit_check']] }

      it { is_expected.to be true }
    end

    context 'when application is means passported on DWP and under 18' do
      let(:means_passport) { Types::MeansPassportType.values }

      it { is_expected.to be true }
    end

    context 'when application is not means passported' do
      let(:means_passport) { [] }

      it { is_expected.to be false }
    end
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

  describe '#status?' do
    subject(:status?) { application.status?(:marked_as_ready) }

    context 'when not marked as ready' do
      before do
        allow(Reviewing::LoadReview).to receive(:call) { review }
        allow(review).to receive(:state).and_return(:open)
      end

      it { is_expected.to be false }
    end

    context 'when marked as ready' do
      before do
        allow(Reviewing::LoadReview).to receive(:call) { review }
        allow(review).to receive(:state).and_return(:marked_as_ready)
      end

      it { is_expected.to be true }
    end
  end
end

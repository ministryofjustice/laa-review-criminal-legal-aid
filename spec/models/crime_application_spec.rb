require 'rails_helper'

RSpec.describe CrimeApplication do
  subject(:application) { described_class.new(attributes) }

  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:review) { instance_double(Reviewing::Review, received?: true, state: :open) }
  let(:assignment) { instance_double(Assigning::Assignment) }

  describe '#applicant_date_of_birth' do
    subject(:applicant_date_of_birth) { application.client_details.applicant.date_of_birth }

    it { is_expected.to eq Date.parse('2001-06-09') }
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

  describe '#means_passported_on_age?' do
    subject(:means_passported_on_age?) { application.means_passported_on_age? }

    let(:attributes) { super().merge({ 'means_passport' => means_passport }) }

    context 'when application is passported on benefits' do
      let(:means_passport) { [Types::MeansPassportType['on_benefit_check']] }

      it { is_expected.to be false }
    end

    context 'when application is passported on age' do
      let(:means_passport) { [Types::MeansPassportType['on_age_under18']] }

      it { is_expected.to be true }
    end

    context 'when application has no means passport' do
      let(:means_passport) { [] }

      it { is_expected.to be false }
    end
  end

  describe '#benefit_type' do
    subject(:benefit_type) { application.client_details.applicant.benefit_type }

    let(:attributes) do
      super().deep_merge({ 'client_details' => { 'applicant' => { 'benefit_type' => passporting_benefit_type } } })
    end

    context 'when application has a benefit type' do
      let(:passporting_benefit_type) { Types::BenefitType['universal_credit'] }

      it { is_expected.to eq 'universal_credit' }
    end

    context 'when application does not have a benefit type' do
      let(:passporting_benefit_type) { nil }

      it { is_expected.to be_nil }
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

  describe '#pse?' do
    subject(:pse?) { application.pse? }

    let(:attributes) { super().merge({ 'application_type' => application_type }) }

    context 'when application is an initial application' do
      let(:application_type) { Types::ApplicationType['initial'] }

      it { is_expected.to be false }
    end

    context 'when application is a post submission evidence application' do
      let(:application_type) { Types::ApplicationType['post_submission_evidence'] }

      it { is_expected.to be true }
    end
  end

  describe '#appeal_no_changes?' do
    subject(:appeal_no_changes?) { application.appeal_no_changes? }

    let(:attributes) do
      super().deep_merge({ 'case_details' => { 'case_type' => 'appeal_to_crown_court',
'appeal_reference_number' => appeal_reference_number } })
    end

    context 'when case type is an appeal_to_crown_court' do
      let(:case_type) { 'appeal_to_crown_court' }

      context 'when there are financial changes' do
        let(:appeal_reference_number) { nil }

        it { is_expected.to be false }
      end

      context 'when there are no financial changes' do
        let(:appeal_reference_number) { 'appeal_usn' }

        it { is_expected.to be true }
      end
    end

    context 'when case type is not an appeal_to_crown_court' do
      let(:case_type) { 'summary_only' }
      let(:appeal_reference_number) { nil }

      it { is_expected.to be false }
    end
  end

  describe '#last_jsa_appointment_date?' do
    subject(:last_jsa_appointment_date?) { application.last_jsa_appointment_date? }

    let(:last_jsa_date) { nil }
    let(:attributes) do
      super().deep_merge('client_details' => { 'applicant' => { 'benefit_type' => 'jsa',
                                                                'last_jsa_appointment_date' => last_jsa_date } })
    end

    context 'when applicant has a jsa benefit type' do
      context 'when applicant has a last jsa appointment date' do
        let(:last_jsa_date) { 'Fri, 12 Jan 2024' }

        it { is_expected.to be true }
      end

      context 'when applicant does not have a last jsa appointment date' do
        it { is_expected.to be false }
      end
    end

    context 'when application does not have a jsa benefit type' do
      it { is_expected.to be false }
    end
  end

  describe '#relevant_ioj_passport' do
    subject(:relevant_ioj_passport) { application.relevant_ioj_passport }

    let(:attributes) do
      super().merge('ioj_passport' => ioj_passport)
    end

    context 'when on offence and age' do
      let(:ioj_passport) { %w[on_age_under18 on_offence] }

      it { is_expected.to eq 'on_age_under18' }
    end

    context 'when on offence' do
      let(:ioj_passport) { ['on_offence'] }

      it { is_expected.to eq 'on_offence' }
    end
  end
end

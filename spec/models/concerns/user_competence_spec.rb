require 'rails_helper'

RSpec.describe UserCompetence do
  let(:user) { User.new }

  describe '#work_streams' do
    subject(:work_streams) { user.work_streams }

    it { is_expected.to be_empty }

    context 'when a user has competencies assigned' do
      before do
        allow(Allocating).to receive(:user_competencies).with(user.id).and_return(
          %w[extradition post_submission_evidence]
        )
      end

      it { is_expected.to eq %w[extradition] }
    end
  end

  describe '#competencies' do
    subject(:competencies) { user.competencies }

    it { is_expected.to be_empty }

    context 'when a user has competencies assigned' do
      before do
        allow(Allocating).to receive(:user_competencies).with(user.id).and_return(
          %w[crime_applications_team post_submission_evidence]
        )
      end

      it { is_expected.to eq %w[crime_applications_team post_submission_evidence] }

      context 'when user is a supervisor' do
        let(:user) { User.new(role: 'supervisor') }

        it { is_expected.to eq %w[crime_applications_team post_submission_evidence] }
      end

      context 'when user is a data analyst' do
        let(:user) { User.new(role: 'data_analyst') }

        it { is_expected.to be_empty }
      end

      context 'when user is an auditor' do
        let(:user) { User.new(role: 'auditor') }

        it { is_expected.to be_empty }
      end
    end
  end

  describe '#application_types_competencies' do
    subject(:application_types_competencies) { user.application_types_competencies }

    it { is_expected.to be_empty }

    context 'when a user has competencies assigned' do
      before do
        allow(Allocating).to receive(:user_competencies).with(user.id).and_return(
          %w[crime_applications_team post_submission_evidence extradition initial]
        )
      end

      it { is_expected.to eq %w[post_submission_evidence initial] }

      context 'when user is a supervisor' do
        let(:user) { User.new(role: 'supervisor') }

        it { is_expected.to eq %w[post_submission_evidence initial] }
      end

      context 'when user is a data analyst' do
        let(:user) { User.new(role: 'data_analyst') }

        it { is_expected.to be_empty }
      end

      context 'when user is a auditor' do
        let(:user) { User.new(role: 'auditor') }

        it { is_expected.to be_empty }
      end
    end
  end
end

require 'rails_helper'

RSpec.describe UserCompetence do
  let(:user) { User.new }

  describe '#work_streams' do
    subject(:work_streams) { user.work_streams }

    it 'defaults to an empty array' do
      expect(work_streams).to eq []
    end

    context 'when a user has competencies assgined' do
      before do
        allow(Allocating).to receive(:user_competencies).with(user.id).and_return(
          %w[extradition post_submission_evidence]
        )
      end

      it 'returns an array of users competencies that are work streams' do
        expect(work_streams).to eq ['extradition']
      end
    end
  end

  describe '#competencies' do
    subject(:competencies) { user.competencies }

    it 'defaults to an empty array' do
      expect(competencies).to eq []
    end

    context 'when a user has competencies assigned' do
      before do
        allow(Allocating).to receive(:user_competencies).with(user.id).and_return(
          %w[crime_applications_team post_submission_evidence]
        )
      end

      it 'returns an array of assigned competencies' do
        expect(competencies).to eq %w[crime_applications_team post_submission_evidence]
      end

      context 'when user is a supervisor' do
        let(:user) { User.new(role: 'supervisor') }

        it 'returns all work_streams regardless of competencies' do
          expect(competencies).to eq %w[criminal_applications_team criminal_applications_team_2 extradition
                                        post_submission_evidence]
        end
      end

      context 'when user is a data analyst' do
        let(:user) { User.new(role: 'data_analyst') }

        it 'returns no competencies' do
          expect(competencies).to be_empty
        end
      end
    end
  end

  describe '#application_types_competencies' do
    subject(:application_types_competencies) { user.application_types_competencies }

    it 'defaults to a initial application type' do
      expect(application_types_competencies).to eq ['initial']
    end

    context 'when a user has post submission evidence assigned' do
      before do
        allow(Allocating).to receive(:user_competencies).with(user.id).and_return(
          %w[crime_applications_team post_submission_evidence]
        )
      end

      it 'returns an array of assigned application types' do
        expect(application_types_competencies).to eq %w[post_submission_evidence initial]
      end

      context 'when user is a supervisor' do
        let(:user) { User.new(role: 'supervisor') }

        it 'returns all application types regardless of assigned competencies' do
          expect(application_types_competencies).to eq %w[post_submission_evidence initial]
        end
      end

      context 'when user is a data analyst' do
        let(:user) { User.new(role: 'data_analyst') }

        it 'returns no application type competencies' do
          expect(application_types_competencies).to be_empty
        end
      end
    end
  end
end

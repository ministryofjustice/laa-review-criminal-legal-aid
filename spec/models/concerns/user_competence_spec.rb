require 'rails_helper'

RSpec.describe UserCompetence do
  let(:user) { User.new }

  describe '#work_streams' do
    subject(:competencies) { user.work_streams }

    it 'defaults to an empty array' do
      expect(competencies).to eq []
    end

    context 'when a user has competencies assgined' do
      before do
        allow(Allocating).to receive(:user_competencies).with(user.id).and_return(
          %w[extradition post_submission_evidence]
        )
      end

      it 'returns an array of users competencies that are work streams' do
        expect(competencies).to eq ['extradition']
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
          expect(competencies).to eq %w[criminal_applications_team criminal_applications_team_2 extradition]
        end
      end

      context 'when user is a data analyst' do
        let(:user) { User.new(role: 'data_analyst') }

        it 'returns no competencies' do
          expect(competencies).to be_empty
        end
      end

      context 'when work stream feature flag is disabled' do
        before do
          allow(FeatureFlags).to receive(:work_stream) {
                                   instance_double(FeatureFlags::EnabledFeature, enabled?: false)
                                 }
        end

        it 'returns all work_streams regardless of competencies' do
          expect(competencies).to eq %w[criminal_applications_team criminal_applications_team_2 extradition]
        end
      end
    end
  end
end

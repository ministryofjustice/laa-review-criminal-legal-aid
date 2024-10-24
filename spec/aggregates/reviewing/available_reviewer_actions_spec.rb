require 'rails_helper'

RSpec.describe Reviewing::AvailableReviewerActions do
  describe '#actions' do
    subject(:actions) do
      described_class.new(state:, application_type:, work_stream:).actions
    end

    context 'when state "open"' do
      let(:state) { Types::ReviewState[:open] }

      context 'when a means tested initial application' do
        let(:application_type) { Types::ApplicationType['initial'] }
        let(:work_stream) { WorkStream.new('criminal_applications_team') }

        it { is_expected.to eq %i[mark_as_ready send_back] }
      end

      context 'when a non-means tested initial application' do
        let(:application_type) { Types::ApplicationType['initial'] }
        let(:work_stream) { WorkStream.new('non_means_tested') }

        it { is_expected.to eq %i[complete send_back] }
      end

      context 'when PSE' do
        let(:application_type) { Types::ApplicationType['post_submission_evidence'] }
        let(:work_stream) { WorkStream.new('non_means_tested') }

        it { is_expected.to eq %i[complete] }
      end

      context 'when CIFC' do
        let(:application_type) { Types::ApplicationType['change_in_financial_circumstances'] }
        let(:work_stream) { WorkStream.new('criminal_applications_team') }

        it { is_expected.to eq %i[mark_as_ready send_back] }
      end
    end

    context 'when state "sent_back"' do
      let(:state) { Types::ReviewState[:sent_back] }

      context 'when a means tested initial application' do
        let(:application_type) { Types::ApplicationType['initial'] }
        let(:work_stream) { WorkStream.new('criminal_applications_team') }

        it { is_expected.to be_empty }
      end

      context 'when a non-means tested initial application' do
        let(:application_type) { Types::ApplicationType['initial'] }
        let(:work_stream) { WorkStream.new('non_means_tested') }

        it { is_expected.to be_empty }
      end

      context 'when CIFC' do
        let(:application_type) { Types::ApplicationType['change_in_financial_circumstances'] }
        let(:work_stream) { WorkStream.new('criminal_applications_team') }

        it { is_expected.to be_empty }
      end
    end

    context 'when state "marked_as_ready"' do
      let(:state) { Types::ReviewState[:marked_as_ready] }

      context 'when a means tested initial application' do
        let(:application_type) { Types::ApplicationType['initial'] }
        let(:work_stream) { WorkStream.new('criminal_applications_team') }

        it { is_expected.to eq %i[complete send_back] }
      end

      context 'when CIFC' do
        let(:application_type) { Types::ApplicationType['change_in_financial_circumstances'] }
        let(:work_stream) { WorkStream.new('criminal_applications_team') }

        it { is_expected.to eq %i[complete send_back] }
      end
    end

    context 'when state "marked_as_ready" and decisions enabled' do
      let(:state) { Types::ReviewState[:marked_as_ready] }

      before do
        allow(FeatureFlags).to receive(:adding_decisions) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
      end

      context 'when a means tested initial application' do
        let(:application_type) { Types::ApplicationType['initial'] }
        let(:work_stream) { WorkStream.new('criminal_applications_team') }

        it { is_expected.to eq %i[send_back] }
      end

      context 'when CIFC' do
        let(:application_type) { Types::ApplicationType['change_in_financial_circumstances'] }
        let(:work_stream) { WorkStream.new('criminal_applications_team') }

        it { is_expected.to eq %i[send_back] }
      end
    end

    context 'when state "completed"' do
      let(:state) { Types::ReviewState[:completed] }

      context 'when a means tested initial application' do
        let(:application_type) { Types::ApplicationType['initial'] }
        let(:work_stream) { WorkStream.new('criminal_applications_team') }

        it { is_expected.to be_empty }
      end

      context 'when a non-means tested initial application' do
        let(:application_type) { Types::ApplicationType['initial'] }
        let(:work_stream) { WorkStream.new('non_means_tested') }

        it { is_expected.to be_empty }
      end

      context 'when PSE' do
        let(:application_type) { Types::ApplicationType['post_submission_evidence'] }
        let(:work_stream) { WorkStream.new('non_means_tested') }

        it { is_expected.to be_empty }
      end

      context 'when CIFC' do
        let(:application_type) { Types::ApplicationType['change_in_financial_circumstances'] }
        let(:work_stream) { WorkStream.new('criminal_applications_team') }

        it { is_expected.to be_empty }
      end
    end

    describe '.for(reviewable)' do
      let(:reviewable) do
        instance_double(
          Reviewing::Review,
          state: :open,
          application_type: 'post_submission_evidence',
          work_stream: 'criminal_applications_team',
          decision_ids: []
        )
      end

      it 'returns an array of available actions' do
        expect(described_class.for(reviewable)).to eq %i[complete]
      end

      context 'when reviewable application_type is nil' do
        let(:reviewable) do
          instance_double(
            Reviewing::Review,
            state: :open,
            application_type: nil,
            work_stream: :criminal_applications_team,
            decision_ids: []
          )
        end

        it 'sets the application_type to initial' do
          expect(described_class.for(reviewable)).to eq %i[mark_as_ready send_back]
        end
      end
    end
  end
end

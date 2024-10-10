require 'rails_helper'

RSpec.describe ApplicationSearchFilter do
  subject(:new) { described_class.new(**params) }

  let(:params) { {} }

  include_context 'with stubbed assignments and reviews'

  describe '#assigned_status_options' do
    subject(:assigned_status_options) { new.assigned_status_options.map(&:first) }

    before do
      User.create!(email: 'Not.Started@example.com', first_name: 'Not', last_name: 'Started')
    end

    it 'list of unassigned, all_assigned, then all caseworkers with assignments or reviews sorted by name' do
      expect(assigned_status_options).to eq(['Unassigned', 'All assigned', 'David Brown', 'John Deere'])
    end
  end

  describe '#age_in_business_days_options' do
    subject(:age_in_business_days_options) { new.age_in_business_days_options }

    it "lists options as '0 days', '1 day', '2 days', '3 days'" do
      expect(age_in_business_days_options.map(&:first)).to eq(['0 days', '1 day', '2 days', '3 days'])
    end
  end

  describe '#datastore_params' do
    subject(:datastore_params) { new.datastore_params }

    context 'when the filter is empty' do
      let(:expected_datastore_params) do
        {
          review_status: %w[application_received returned_to_provider ready_for_assessment assessment_completed],
        }
      end

      it 'returns the correct datastore api search params for all applications' do
        expect(datastore_params).to eq(expected_datastore_params)
      end
    end

    context 'when all filters set' do
      let(:params) do
        {
          applicant_date_of_birth: '1970-10-10', assigned_status: david.id,
          search_text: 'David 100003', application_status: 'sent_back',
          submitted_after: '2022-12-22', submitted_before: '2022-12-21',
          work_stream: %w[criminal_applications_team]
        }
      end

      let(:expected_datastore_params) do
        {
          applicant_date_of_birth: Date.parse('1970-10-10'),
          application_id_in: davids_applications,
          submitted_after: Date.parse('2022-12-22'),
          submitted_before: Date.parse('2022-12-21'),
          search_text: 'David 100003',
          review_status: %w[returned_to_provider],
          work_stream: %w[criminal_applications_team],
        }
      end

      it 'returns the correct datastore api search params' do
        expect(datastore_params).to eq expected_datastore_params
      end
    end

    context 'when we know a datastore search result will be empty from the review filters' do
      let(:params) do
        { search_text: 'David 100003', assigned_status: SecureRandom.uuid }
      end

      it 'knows if a datastore search is required' do
        expect(new.datastore_results_will_be_empty?).to be true
      end
    end
  end

  describe 'datastore date params' do
    it 'BST dates can be correctly converted to UCT' do
      date = Date.parse('2023-07-01')
      report = described_class.new(submitted_after: date, submitted_before: date)
      expect(report.datastore_params.fetch(:submitted_after)).to eq Time.iso8601('2023-06-30T23:00:00Z')
      expect(report.datastore_params.fetch(:submitted_before)).to eq Time.iso8601('2023-06-30T23:00:00Z')
    end

    it 'GMT dates can be correctly converted to UCT' do
      date = Date.parse('2023-01-01')
      report = described_class.new(submitted_after: date, submitted_before: date)
      expect(report.datastore_params.fetch(:submitted_after)).to eq Time.iso8601('2023-01-01T00:00:00Z')
      expect(report.datastore_params.fetch(:submitted_before)).to eq Time.iso8601('2023-01-01T00:00:00Z')
    end
  end

  describe 'translating the review filters into datastore search params' do
    let(:application_id_in) { new.datastore_params.fetch(:application_id_in) }

    context 'when a user is specified' do
      let(:params) { { assigned_status: john.id } }

      it 'sets "application_id_in" to user\'s "assignment_id"s and "reviewed_id"s' do
        expect(application_id_in).to eq(johns_applications)
      end
    end

    context 'when all_assigned is specified' do
      let(:params) { { assigned_status: 'assigned' } }

      it 'sets "application_id_in" to all assignment_ids' do
        expect(application_id_in).to eq current_assignment_ids
      end
    end

    context 'when unassigned is specified' do
      let(:params) { { assigned_status: 'unassigned' } }

      it 'sets "application_id_in" to all unassigned application ids' do
        expect(application_id_in).to eq unassigned_application_ids
      end
    end

    describe 'when multiple review filters are set' do
      context 'when at least one application satisfies both review filters' do
        let(:params) { { assigned_status: 'unassigned', age_in_business_days: 0 } }

        it 'sets the intersection as the "application_id_in"' do
          expect(application_id_in).to eq unassigned_application_ids
        end

        it 'does not know that datastore_results_will_be_empty' do
          expect(new.datastore_results_will_be_empty?).to be false
        end
      end

      context 'when no application satisfies both review filters' do
        let(:params) { { assigned_status: 'unassigned', age_in_business_days: 1 } }

        it '"application_id_in" are empty' do
          expect(application_id_in).to be_empty
        end

        it 'knows that the datastore_results_will_be_empty' do
          expect(new.datastore_results_will_be_empty?).to be true
        end
      end
    end
  end
end

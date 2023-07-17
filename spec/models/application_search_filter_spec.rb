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

  describe '#datastore_params' do
    subject(:datastore_params) { new.datastore_params }

    let(:expected_datastore_params) do
      {
        applicant_date_of_birth: nil,
        application_id_in: [],
        application_id_not_in: [],
        review_status: %w[application_received ready_for_assessment],
        submitted_after: nil,
        submitted_before: nil,
        search_text: nil
      }
    end

    context 'when the filter is empty' do
      it 'returns the correct datastore api search params' do
        expect(datastore_params).to eq(expected_datastore_params)
      end
    end

    context 'when all filters set' do
      let(:params) do
        {
          applicant_date_of_birth: '1970-10-10', assigned_status: david.id,
          search_text: 'David 100003', application_status: 'sent_back',
          submitted_after: '2022-12-22', submitted_before: '2022-12-21'
        }
      end

      let(:expected_datastore_params) do
        {
          applicant_date_of_birth: Date.parse('1970-10-10'),
          application_id_in: davids_applications,
          submitted_after: Date.parse('2022-12-22'),
          submitted_before: Date.parse('2022-12-21'),
          search_text: 'David 100003',
          application_id_not_in: [],
          review_status: %w[returned_to_provider]
        }
      end

      it 'returns the correct datastore api search params' do
        expect(datastore_params).to eq expected_datastore_params
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

  describe 'translating the assigned_status into search params' do
    let(:application_id_in) { new.datastore_params.fetch(:application_id_in) }
    let(:application_id_not_in) { new.datastore_params.fetch(:application_id_not_in) }

    context 'when a user is specified' do
      let(:params) { { assigned_status: john.id } }

      it 'sets "application_id_in" to user\'s "assignment_id"s and "reviewed_id"s' do
        expect(application_id_in).to eq(johns_applications)

        expect(application_id_not_in).to be_empty
      end
    end

    context 'when all_assigned is specified' do
      let(:params) { { assigned_status: 'assigned' } }

      it 'sets "application_id_in" to all assignment_ids' do
        expect(application_id_in).to eq current_assignment_ids
        expect(application_id_not_in).to be_empty
      end
    end

    context 'when unassigned is specified' do
      let(:params) { { assigned_status: 'unassigned' } }

      it 'sets "application_id_not_in" to user\'s "assignment_id"s' do
        expect(application_id_not_in).to eq current_assignment_ids
        expect(application_id_in).to be_empty
      end
    end
  end
end

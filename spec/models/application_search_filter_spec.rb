require 'rails_helper'

RSpec.describe ApplicationSearchFilter do
  subject(:new) { described_class.new(**params) }

  let(:params) { {} }

  let(:david) do
    User.create!(
      auth_oid: '35d581ba-b1f5-4d96-8b1d-233bfe67dfe5',
      first_name: 'David',
      last_name: 'Brown',
      email: 'David.Browneg@justice.gov.uk'
    )
  end

  let(:john) do
    User.create!(
      auth_oid: '992c1667-745f-4eda-848b-eec7cd92d7fa',
      first_name: 'John',
      last_name: 'Deere',
      email: 'John.Deereeg@justice.gov.uk'
    )
  end

  before do
    [SecureRandom.uuid, SecureRandom.uuid].each do |assignment_id|
      Assigning::AssignToUser.new(
        assignment_id: assignment_id,
        user_id: john.id,
        to_whom_id: john.id
      ).call
    end

    Assigning::AssignToUser.new(
      assignment_id: SecureRandom.uuid,
      user_id: david.id,
      to_whom_id: david.id
    ).call
  end

  describe '#assigned_status_options' do
    subject(:assigned_status_options) { new.assigned_status_options }

    it 'list of unassigned, all_assigned, then all assignees sorted by name' do
      expect(assigned_status_options.map(&:first)).to eq(
        ['Unassigned', 'All assigned', 'David Brown', 'John Deere']
      )
    end
  end

  describe '#datastore_params' do
    subject(:datastore_params) { new.datastore_params }

    context 'when the filter is empty' do
      it 'returns the correct datastore api search params' do
        expect(datastore_params).to eq({
                                         applicant_date_of_birth: nil, application_id_in: [],
            application_id_not_in: [], status: ['submitted'],
            submitted_after: nil, submitted_before: nil, search_text: nil
                                       })
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

      let(:expected_datstore_params) do
        {
          applicant_date_of_birth: Date.parse('1970-10-10'),
          application_id_in: david.current_assignments.pluck(:assignment_id),
          submitted_after: Date.parse('2022-12-22'),
          submitted_before: Date.parse('2022-12-21'),
          search_text: 'David 100003',
          application_id_not_in: [],
          status: ['returned']
        }
      end

      it 'returns the correct datastore api search params' do
        expect(datastore_params).to eq expected_datstore_params
      end
    end
  end

  describe 'translating the assigned_status into search params' do
    let(:application_id_in) { new.datastore_params.fetch(:application_id_in) }
    let(:application_id_not_in) { new.datastore_params.fetch(:application_id_not_in) }

    context 'when a user is specified' do
      let(:params) { { assigned_status: john.id } }

      it 'sets "application_id_in" to user\'s "assignment_id"s' do
        expect(application_id_in).to eq(
          john.current_assignments.pluck(:assignment_id)
        )

        expect(application_id_not_in).to be_empty
      end
    end

    context 'when all_assigned is specified' do
      let(:params) { { assigned_status: 'assigned' } }

      it 'sets "application_id_in" to all assignment_ids' do
        expect(application_id_in).to eq(CurrentAssignment.pluck(:assignment_id))
        expect(application_id_not_in).to be_empty
      end
    end

    context 'when unassigned is specified' do
      let(:params) { { assigned_status: 'unassigned' } }

      it 'sets "application_id_not_in" to user\'s "assignment_id"s' do
        expect(application_id_not_in).to eq(CurrentAssignment.pluck(:assignment_id))
        expect(application_id_in).to be_empty
      end
    end
  end
end

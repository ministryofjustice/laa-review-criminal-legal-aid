require 'rails_helper'

describe CaseworkerReports::WorkQueueProjection do
  let(:stream_name) do
    CaseworkerReports.stream_name(
      date: Time.zone.now.in_time_zone('London').to_date,
      interval: :daily
    )
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe '#dataset' do
    subject(:dataset) { described_class.new(stream_name:).dataset }

    let(:zoe_id) { SecureRandom.uuid }
    let(:bob_id) { SecureRandom.uuid }

    let(:events) do
      [
        Assigning::AssignedToUser.new(data: { to_whom_id: zoe_id, assignment_id: cat1_review }),
        Assigning::AssignedToUser.new(data: { to_whom_id: zoe_id, assignment_id: pse_review }),
        Assigning::AssignedToUser.new(data: { to_whom_id: zoe_id, assignment_id: pse_review }),
        Assigning::UnassignedFromUser.new(data: { from_whom_id: zoe_id, assignment_id: cat1_review }),
        Assigning::ReassignedToUser.new(data: { from_whom_id: bob_id, to_whom_id: zoe_id,
assignment_id: extradition_review }),
        Assigning::ReassignedToUser.new(data: { from_whom_id: bob_id, to_whom_id: zoe_id,
assignment_id: pse_review }),
        Reviewing::SentBack.new(data: { user_id: zoe_id, application_id: cat2_review }),
        Reviewing::Completed.new(data: { user_id: zoe_id, application_id: cat1_review }),
        Reviewing::Completed.new(data: { user_id: zoe_id, application_id: extradition_review }),

        Assigning::AssignedToUser.new(data: { to_whom_id: bob_id, assignment_id: non_means_review }),
        Assigning::AssignedToUser.new(data: { to_whom_id: bob_id, assignment_id: pse_review }),
        Assigning::AssignedToUser.new(data: { to_whom_id: bob_id, assignment_id: extradition_review }),
        Assigning::UnassignedFromUser.new(data: { from_whom_id: bob_id, assignment_id: pse_review }),
        Assigning::ReassignedToUser.new(data: { from_whom_id: zoe_id, to_whom_id: bob_id,
assignment_id: cat1_review }),
        Reviewing::SentBack.new(data: { user_id: bob_id, application_id: pse_review }),
        Reviewing::Completed.new(data: { user_id: bob_id, application_id: non_means_review }),
      ]
    end

    let(:cat1_review) { SecureRandom.uuid }
    let(:cat2_review) { SecureRandom.uuid }
    let(:extradition_review) { SecureRandom.uuid }
    let(:non_means_review) { SecureRandom.uuid }
    let(:pse_review) { SecureRandom.uuid }

    let(:bob) { dataset[bob_id] }
    let(:zoe) { dataset[zoe_id] }

    before do
      event_store = Rails.configuration.event_store
      CaseworkerReports::Configuration.new.call(event_store)

      allow(User).to receive(:name_for).with(zoe_id).and_return('Zoe Blogs')
      allow(User).to receive(:name_for).with(bob_id).and_return('Bob Smith')

      Review.insert_all( # rubocop:disable Rails/SkipsModelValidations
        [
          { application_id: cat1_review, work_stream: 'criminal_applications_team', application_type: 'initial' },
          { application_id: cat2_review, work_stream: 'criminal_applications_team_2', application_type: 'initial' },
          { application_id: extradition_review, work_stream: 'extradition', application_type: 'initial' },
          { application_id: non_means_review, work_stream: 'non_means_tested', application_type: 'initial' },
          { application_id: pse_review, work_stream: 'criminal_applications_team_2',
application_type: 'post_submission_evidence' },
        ]
      )

      events.each { |event| event_store.publish(event) }
    end

    it 'includes user name' do
      expect(zoe.values.first.user_name).to eq('Zoe Blogs')
      expect(bob.values.first.user_name).to eq('Bob Smith')
    end

    # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
    describe 'per work queue' do
      # rubocop:disable RSpec/IndexedLet
      let(:zoe_cat1) { zoe['criminal_applications_team'] }
      let(:zoe_cat2) { zoe['criminal_applications_team_2'] }
      let(:zoe_extradition) { zoe['extradition'] }
      let(:zoe_pse) { zoe['post_submission_evidence'] }

      let(:bob_cat1) { bob['criminal_applications_team'] }
      let(:bob_cat2) { bob['criminal_applications_team_2'] }
      let(:bob_extradition) { bob['extradition'] }
      let(:bob_non_means) { bob['non_means_tested'] }
      let(:bob_pse) { bob['post_submission_evidence'] }
      # rubocop:enable RSpec/IndexedLet

      it 'includes work queue' do
        expect(zoe_cat1.work_queue).to eq('criminal_applications_team')
        expect(zoe_cat2.work_queue).to eq('criminal_applications_team_2')
        expect(zoe_extradition.work_queue).to eq('extradition')
        expect(zoe_pse.work_queue).to eq('post_submission_evidence')

        expect(bob_cat1.work_queue).to eq('criminal_applications_team')
        expect(bob_cat2.work_queue).to eq('criminal_applications_team_2')
        expect(bob_extradition.work_queue).to eq('extradition')
        expect(bob_non_means.work_queue).to eq('non_means_tested')
        expect(bob_pse.work_queue).to eq('post_submission_evidence')
      end

      it 'includes event counts' do
        expect(zoe_cat1.as_json).to include(
          'assigned_to_user' => 1,
          'completed_by_user' => 1,
          'reassigned_from_user' => 1,
          'reassigned_to_user' => 0,
          'sent_back_by_user' => 0,
          'unassigned_from_user' => 1
        )
        expect(zoe_cat2.as_json).to include(
          'assigned_to_user' => 2,
          'completed_by_user' => 0,
          'reassigned_from_user' => 0,
          'reassigned_to_user' => 1,
          'sent_back_by_user' => 1,
          'unassigned_from_user' => 0
        )
        expect(zoe_extradition.as_json).to include(
          'assigned_to_user' => 0,
          'completed_by_user' => 1,
          'reassigned_from_user' => 0,
          'reassigned_to_user' => 1,
          'sent_back_by_user' => 0,
          'unassigned_from_user' => 0
        )
        expect(zoe_pse.as_json).to include(
          'assigned_to_user' => 2,
          'completed_by_user' => 0,
          'reassigned_from_user' => 0,
          'reassigned_to_user' => 1,
          'sent_back_by_user' => 0,
          'unassigned_from_user' => 0
        )
        expect(bob_cat1.as_json).to include(
          'assigned_to_user' => 0,
          'completed_by_user' => 0,
          'reassigned_from_user' => 0,
          'reassigned_to_user' => 1,
          'sent_back_by_user' => 0,
          'unassigned_from_user' => 0
        )
        expect(bob_cat2.as_json).to include(
          'assigned_to_user' => 1,
          'completed_by_user' => 0,
          'reassigned_from_user' => 1,
          'reassigned_to_user' => 0,
          'sent_back_by_user' => 1,
          'unassigned_from_user' => 1
        )
        expect(bob_extradition.as_json).to include(
          'assigned_to_user' => 1,
          'completed_by_user' => 0,
          'reassigned_from_user' => 1,
          'reassigned_to_user' => 0,
          'sent_back_by_user' => 0,
          'unassigned_from_user' => 0
        )
        expect(bob_non_means.as_json).to include(
          'assigned_to_user' => 1,
          'completed_by_user' => 1,
          'reassigned_from_user' => 0,
          'reassigned_to_user' => 0,
          'sent_back_by_user' => 0,
          'unassigned_from_user' => 0
        )
        expect(bob_pse.as_json).to include(
          'assigned_to_user' => 1,
          'completed_by_user' => 0,
          'reassigned_from_user' => 1,
          'reassigned_to_user' => 0,
          'sent_back_by_user' => 1,
          'unassigned_from_user' => 1
        )
      end

      it 'records the total number assigned to the user' do
        expect(zoe_cat1.total_assigned_to_user).to eq(1)
        expect(zoe_cat2.total_assigned_to_user).to eq(3)
        expect(zoe_extradition.total_assigned_to_user).to eq(1)
        expect(zoe_pse.total_assigned_to_user).to eq(3)
        expect(bob_cat1.total_assigned_to_user).to eq(1)
        expect(bob_cat2.total_assigned_to_user).to eq(1)
        expect(bob_extradition.total_assigned_to_user).to eq(1)
        expect(bob_non_means.total_assigned_to_user).to eq(1)
        expect(bob_pse.total_assigned_to_user).to eq(1)
      end

      it 'records the total number unassigned from the user' do
        expect(zoe_cat1.total_unassigned_from_user).to eq(2)
        expect(zoe_cat2.total_unassigned_from_user).to eq(0)
        expect(zoe_extradition.total_unassigned_from_user).to eq(0)
        expect(zoe_pse.total_unassigned_from_user).to eq(0)
        expect(bob_cat1.total_unassigned_from_user).to eq(0)
        expect(bob_cat2.total_unassigned_from_user).to eq(2)
        expect(bob_extradition.total_unassigned_from_user).to eq(1)
        expect(bob_non_means.total_unassigned_from_user).to eq(0)
        expect(bob_pse.total_unassigned_from_user).to eq(2)
      end

      it 'records the total number closed by the user' do
        expect(zoe_cat1.total_closed_by_user).to eq(1)
        expect(zoe_cat2.total_closed_by_user).to eq(1)
        expect(zoe_extradition.total_closed_by_user).to eq(1)
        expect(zoe_pse.total_closed_by_user).to eq(0)
        expect(bob_cat1.total_closed_by_user).to eq(0)
        expect(bob_cat2.total_closed_by_user).to eq(1)
        expect(bob_extradition.total_closed_by_user).to eq(0)
        expect(bob_non_means.total_closed_by_user).to eq(1)
        expect(bob_pse.total_closed_by_user).to eq(1)
      end
    end
    # rubocop:enable RSpec/ExampleLength,RSpec/MultipleExpectations
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end

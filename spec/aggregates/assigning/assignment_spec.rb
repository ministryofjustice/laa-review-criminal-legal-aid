require 'rails_helper'

describe Assigning::Assignment do
  subject(:assignment) { described_class.new(SecureRandom.uuid) }

  let(:user_id) { SecureRandom.uuid }
  let(:to_whom_id) { SecureRandom.uuid }

  it 'is initially "unassigned"' do
    expect(assignment).to be_unassigned
  end

  it 'is initially has no assignee_id' do
    expect(assignment.assignee_id).to be_nil
  end

  describe 'assigning to a user' do
    before do
      assignment.assign_to_user(user_id:, to_whom_id:)
    end

    it 'is becomes "assigned"' do
      expect(assignment).to be_assigned
      expect(assignment).not_to be_unassigned
    end

    it 'is is assigned to "to_whom_id"' do
      expect(assignment.assignee_id).to eq(to_whom_id)
    end

    it 'creates an event' do
      expect(assignment.unpublished_events.map(&:event_type)).to match [
        'Assigning::AssignedToUser'
      ]
    end
  end

  describe 'unassigning a user' do
    before do
      assignment.assign_to_user(user_id:, to_whom_id:)
      assignment.unassign_from_user(user_id: user_id, from_whom_id: to_whom_id)
    end

    it 'is becomes "assigned"' do
      expect(assignment).to be_unassigned
      expect(assignment).not_to be_assigned
    end

    it 'is is assigned to "to_whom_id"' do
      expect(assignment.assignee_id).to be_nil
    end

    it 'creates an event' do
      expect(assignment.unpublished_events.map(&:event_type)).to match [
        'Assigning::AssignedToUser', 'Assigning::UnassignedFromUser'
      ]
    end
  end

  describe 'reassigning a user' do
    let(:from_whom_id) { SecureRandom.uuid }

    before do
      assignment.assign_to_user(user_id: user_id, to_whom_id: from_whom_id)
      assignment.reassign_to_user(user_id:, from_whom_id:, to_whom_id:)
    end

    it 'is remains "assigned"' do
      expect(assignment).to be_assigned
      expect(assignment).not_to be_unassigned
    end

    it 'is is assigned to "to_whom_id"' do
      expect(assignment.assignee_id).to eq(to_whom_id)
    end

    it 'creates an event' do
      expect(assignment.unpublished_events.map(&:event_type)).to match [
        'Assigning::AssignedToUser', 'Assigning::ReassignedToUser'
      ]
    end
  end
end

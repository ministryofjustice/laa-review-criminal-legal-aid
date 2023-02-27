require 'rails_helper'

RSpec.describe Assignable do
  let(:user) do
    instance_double(User, id: 1)
  end

  let(:assignment) do
    instance_double(
      Assigning::Assignment,
      assignee_id: 1,
      assigned?: true,
      assigned_to?: true,
      unassigned?: false
    )
  end

  let(:assignable) do
    Class.new do
      include Assignable
      def id
        1
      end
    end.new
  end

  before do
    allow(Assigning::LoadAssignment).to receive(:call).and_return(assignment)
  end

  describe '#assignment' do
    it 'loads the assignment for the assignable object' do
      expect(assignable.assignment).to eq(assignment)
    end
  end

  describe '#assignee_name' do
    it 'returns the name of the assignee' do
      allow(User).to receive(:name_for).and_return('John Doe')

      expect(assignable.assignee_name).to eq('John Doe')
    end

    it 'returns nil if the assignee ID is nil' do
      allow(assignment).to receive(:assignee_id).and_return(nil)

      expect(assignable.assignee_name).to be_nil
    end
  end

  describe 'delegated methods' do
    it 'delegates #assignee_id' do
      assignable.assignee_id
      expect(assignment).to have_received(:assignee_id)
    end

    it 'delegates #assigned?' do
      assignable.assigned?
      expect(assignment).to have_received(:assigned?)
    end

    it 'delegates #assigned_to?' do
      assignable.assigned_to?(user.id)
      expect(assignment).to have_received(:assigned_to?)
    end

    it 'delgates #unassigned?' do
      assignable.unassigned?
      expect(assignment).to have_received(:unassigned?)
    end
  end
end

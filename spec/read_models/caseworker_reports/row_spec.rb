require 'rails_helper'

describe CaseworkerReports::Row do
  subject(:row) { described_class.new(user_id) }

  let(:user_id) { SecureRandom.uuid }

  before do
    allow(User).to receive(:name_for).with(user_id).and_return('Zoe Blogs')
  end

  describe '#assign' do
    it 'increments "#assigned_to_user"' do
      expect { row.assign }.to change { row.assigned_to_user }.from(0).to(1)
    end
  end

  describe '#reassign_to' do
    it 'increments "#reassign_toed_to_user"' do
      expect { row.reassign_to }.to change { row.reassigned_to_user }.from(0).to(1)
    end
  end

  describe '#unassign' do
    it 'increments "#unassigned_to_user"' do
      expect { row.unassign }.to change { row.unassigned_from_user }.from(0).to(1)
    end
  end

  describe '#send_back' do
    it 'increments "#send_backed_to_user"' do
      expect { row.send_back }.to change { row.sent_back_by_user }.from(0).to(1)
    end
  end

  describe '#complete' do
    it 'increments "#completeed_to_user"' do
      expect { row.complete }.to change { row.completed_by_user }.from(0).to(1)
    end
  end

  describe '#total_closed_by_user' do
    subject(:total) { row.total_closed_by_user }

    it 'is initially nil' do
      expect(total).to be 0
    end

    it 'returns the sum of sent back and completed' do
      setup_row
      expect(total).to be 3
    end
  end

  describe '#total_assigned_to_user' do
    subject(:total) { row.total_assigned_to_user }

    it 'is initially nil' do
      expect(total).to be 0
    end

    it 'returns the sum of assigned and reassigned' do
      setup_row
      expect(total).to be 21
    end
  end

  describe '#total_unassigned_from_user' do
    subject(:total) { row.total_unassigned_from_user }

    it 'is initially nil' do
      expect(total).to be 0
    end

    it 'returns the sum of unassigned and reassigned' do
      setup_row
      expect(total).to be 8
    end
  end

  describe '#percentage_closed_by_user' do
    subject(:percentage_closed_by_user) { row.percentage_closed_by_user }

    it 'is initially nil' do
      expect(percentage_closed_by_user).to be_nil
    end

    it 'returns the correct percentage' do
      setup_row
      expect(percentage_closed_by_user).to be 14
    end
  end

  describe '#percentage_unassigned_from_user' do
    subject(:percentage_unassigned_from_user) { row.percentage_unassigned_from_user }

    it 'is initially nil' do
      expect(percentage_unassigned_from_user).to be_nil
    end

    it 'returns the correct percentage' do
      setup_row
      expect(percentage_unassigned_from_user).to be 38
    end
  end

  # total_assigned = 21
  # total_unassigned = 8
  # total_closed = 3
  def setup_row
    13.times { row.assign }
    8.times { row.reassign_to }
    5.times { row.reassign_from }
    3.times { row.unassign }
    2.times { row.complete }
    row.send_back
  end
end

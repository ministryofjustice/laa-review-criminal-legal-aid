require 'rails_helper'

describe CaseworkerReports::Projection do
  let(:stream_name) do
    CaseworkerReports.stream_name(
      date: Time.zone.now.in_time_zone('London').to_date,
      interval: :daily
    )
  end

  describe '#dataset' do
    subject(:dataset) { described_class.new(stream_name:).dataset }

    let(:zoe_id) { SecureRandom.uuid }
    let(:bob_id) { SecureRandom.uuid }

    let(:events) do
      [
        Assigning::AssignedToUser.new(data: { to_whom_id: zoe_id }),
        Assigning::AssignedToUser.new(data: { to_whom_id: bob_id }),
        Assigning::UnassignedFromUser.new(data: { from_whom_id: zoe_id }),
        Assigning::AssignedToUser.new(data: { to_whom_id: zoe_id }),
        Assigning::ReassignedToUser.new(data: { from_whom_id: bob_id, to_whom_id: zoe_id }),
        Reviewing::Completed.new(data: { user_id: zoe_id }),
        Reviewing::SentBack.new(data: { user_id: zoe_id })
      ]
    end

    let(:bob) { dataset[bob_id] }
    let(:zoe) { dataset[zoe_id] }

    before do
      event_store = Rails.configuration.event_store
      CaseworkerReports::Configuration.new.call(event_store)

      allow(User).to receive(:name_for).with(zoe_id).and_return('Zoe Blogs')
      allow(User).to receive(:name_for).with(bob_id).and_return('Bob Smith')

      events.each { |event| event_store.publish(event) }
    end

    it 'includes user name' do
      expect(zoe.user_name).to eq('Zoe Blogs')
      expect(bob.user_name).to eq('Bob Smith')
    end

    it 'records the total number assinged to the user' do
      expect(zoe.total_assigned_to_user).to eq(3)
      expect(bob.total_assigned_to_user).to eq(1)
    end

    it 'records the total number unassinged from the user' do
      expect(zoe.total_unassigned_from_user).to eq(1)
      expect(bob.total_unassigned_from_user).to eq(1)
    end

    it 'records the total number closed by the user' do
      expect(zoe.total_closed_by_user).to eq(2)
      expect(bob.total_closed_by_user).to eq(0)
    end
  end
end

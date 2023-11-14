# View Object for an allocation history item

class AllocationHistoryItem
  def initialize(event)
    @event = event
  end

  delegate :data, :timestamp, :event_type, to: :@event

  def supervisor_name
    return '--' unless supervisor_id

    User.name_for supervisor_id
  end

  def supervisor_id
    @supervisor_id ||= data.fetch(:by_whom_id, nil)
  end
end

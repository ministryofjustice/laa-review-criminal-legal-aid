class AllocationHistory < ApplicationStruct
  attribute :user_id, Types::Uuid

  def items
    @items ||= events.map { |event| AllocationHistoryItem.new(event) }
  end

  private

  def events
    Allocating.user_events(user_id).backward
  end
end

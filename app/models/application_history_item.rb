#
# View Object for an application history item
#
class ApplicationHistoryItem < ApplicationStruct
  attribute :user_name, Types::String
  attribute :timestamp, Types::Nominal::DateTime
  attribute :event_type, Types::String
  attribute? :event_data, Types::Hash

  def to_partial_path
    ["#{super}s", event_type.underscore.tr('/', '_')].join '/'
  end

  class << self
    def from_event(event)
      user_id = event.data.fetch(:user_id)
      new(
        user_name: User.name_for(user_id),
        timestamp: event.timestamp,
        event_type: event.event_type,
        event_data: event.data
      )
    end
  end
end

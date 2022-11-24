class ApplicationHistoryEvent < ApplicationStruct
  attribute :user_id, Types::Uuid.optional
  attribute :user_name, Types::String
  attribute :timestamp, Types::Nominal::DateTime
  attribute :event_type, Types::String

  def description
    I18n.t(
      event_type.underscore.tr('/', '.'),
      scope: 'event.description',
      who_user_name: user_name,
      whom_user_name: user_name
    )
  end

  class << self
    def from_event(event)
      ApplicationHistoryEvent.new(
        user_id: event.data.fetch(:user_id),
        user_name: event.data.fetch(:user_name),
        timestamp: event.timestamp,
        event_type: event.event_type
      )
    end
  end
end

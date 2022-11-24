#
# View Object for an application history event
#
class ApplicationHistoryEvent < ApplicationStruct
  VIEWABLE_DATA = %i[from_whom_name to_whom_name].freeze

  attribute :user_id, Types::Uuid.optional
  attribute :user_name, Types::String
  attribute :timestamp, Types::Nominal::DateTime
  attribute :event_type, Types::String
  attribute :viewable_data, Types::Hash.default({}.freeze)

  def description
    I18n.t(
      event_type.underscore.tr('/', '.'),
      scope: 'event.description',
      **viewable_data
    )
  end

  class << self
    def from_event(event)
      ApplicationHistoryEvent.new(
        user_id: event.data.fetch(:user_id),
        user_name: event.data.fetch(:user_name),
        timestamp: event.timestamp,
        event_type: event.event_type,
        viewable_data: event.data.slice(*VIEWABLE_DATA)
      )
    end
  end
end

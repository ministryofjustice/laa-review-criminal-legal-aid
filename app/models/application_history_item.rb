#
# View Object for an application history item
#
class ApplicationHistoryItem < ApplicationStruct
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
      user_id = event.data.fetch(:user_id)

      new(
        user_id: user_id,
        user_name: User.name_for(user_id),
        timestamp: event.timestamp,
        event_type: event.event_type,
        viewable_data: viewable_data_for_event(event)
      )
    end

    def viewable_data_for_event(event)
      case event.event_type
      when 'Assigning::AssignedToUser'
        { to_whom_name: User.name_for(event.data.fetch(:to_whom_id)) }
      when 'Assigning::UnassignedFromUser'
        { from_whom_name: User.name_for(event.data.fetch(:from_whom_id)) }
      when 'Assigning::ReassignedToUser'
        {
          to_whom_name: User.name_for(event.data.fetch(:to_whom_id)),
          from_whom_name: User.name_for(event.data.fetch(:from_whom_id))
        }
      end
    end
  end
end

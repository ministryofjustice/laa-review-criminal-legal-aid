#
# View Object for an application history item
#
class ApplicationHistoryItem < ApplicationStruct
  attribute :user_name, Types::String
  attribute :timestamp, Types::Nominal::Time
  attribute :event_type, Types::String
  attribute :event_data, Types::Hash
  attribute? :application_type, Types::String.optional
  attribute? :return_details, Types::String.optional
  attribute? :ordinal_position, Types::Integer.optional
  attribute? :ordinal_total, Types::Integer.optional

  def to_partial_path
    ["#{super}s", event_type.underscore.tr('/', '_')].join '/'
  end

  class << self
    def from_event(event, application, ordinal_position: nil, ordinal_total: nil)
      user_name = user_name(event, application)
      timestamp = time_stamp(event, application)
      event_data = event.data
      event_type = event.event_type
      application_type = application&.application_type
      return_details = application&.return_details&.details if event.event_type == 'Reviewing::SentBack'

      new(user_name:, timestamp:, event_type:, event_data:, application_type:, return_details:, ordinal_position:,
          ordinal_total:)
    end

    private

    def user_name(event, application)
      case event.event_type
      when 'Reviewing::ApplicationReceived', 'Reviewing::Superseded'
        application.legal_rep_name
      when 'Deleting::Archived'
        'Provider'
      when 'Deleting::SoftDeleted'
        'System'
      else
        User.name_for(event.data.fetch(:user_id))
      end
    end

    def time_stamp(event, application)
      case event.event_type
      when 'Reviewing::ApplicationReceived', 'Reviewing::Superseded'
        application.submitted_at
      when 'Deleting::Archived'
        event.data[:archived_at]
      when 'Deleting::SoftDeleted'
        event.data[:soft_deleted_at]
      else
        event.timestamp
      end
    end
  end
end

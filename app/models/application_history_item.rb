#
# View Object for an application history item
#
class ApplicationHistoryItem < ApplicationStruct
  attribute :user_name, Types::String
  attribute :timestamp, Types::Nominal::Time
  attribute :event_type, Types::String
  attribute :event_data, Types::Hash

  def to_partial_path
    ["#{super}s", event_type.underscore.tr('/', '_')].join '/'
  end

  class << self
    def from_event(event, application)
      if %w[Reviewing::ApplicationReceived Reviewing::Superseded].include? event.event_type
        user_name = application.legal_rep_name
        timestamp = application.submitted_at
      else
        user_name = User.name_for(event.data.fetch(:user_id))
        timestamp = event.timestamp
      end

      event_data = event.data
      event_type = event.event_type
      new(user_name:, timestamp:, event_type:, event_data:)
    end
  end
end

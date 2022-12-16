#
# Read Model for Application History
#
class ApplicationHistory < ApplicationStruct
  EVENT_TYPES = [
    Assigning::AssignedToUser,
    Assigning::UnassignedFromUser,
    Assigning::ReassignedToUser
  ].freeze

  attribute :application, Types.Instance(CrimeApplication)

  def events
    @events ||= load_events
  end

  def user_names
    @user_names ||= {}
  end

  private

  def load_events
    RailsEventStore::Projection
      .from_stream("Assigning$#{application.id}")
      .init(-> { [application_submitted_event] })
      .when(ApplicationHistory::EVENT_TYPES,
            lambda { |state, event|
              state << ApplicationHistoryEvent.from_event(event)
            }).run(Rails.application.config.event_store).reverse
  end

  # NOTE: provider name is not yet availble in the data.
  # Tihs is a fake submission event. It will be replace by a
  # real one on import from the datastore.
  def application_submitted_event
    ApplicationHistoryEvent.new(
      user_id: nil,
      user_name: 'Provider Name',
      timestamp: application.submitted_at,
      event_type: 'Application::Submitted'
    )
  end
end

class ApplicationHistory < ApplicationStruct
  EVENT_TYPES = [
    Assigning::AssignedToUser,
    Assigning::UnassignedFromUser,
    Assigning::ReassignedToUser
  ].freeze

  attribute :application, Types.Instance(CrimeApplication)

  def items
    @items ||= load_from_events
  end

  private

  def load_from_events
    RailsEventStore::Projection
      .from_stream("Assigning$#{application.id}")
      .init(-> { [application_submitted_item] })
      .when(ApplicationHistory::EVENT_TYPES,
            lambda { |state, event|
              state << ApplicationHistoryItem.from_event(event)
            }).run(Rails.application.config.event_store).reverse
  end

  # NOTE: provider name is not yet availble in the data.
  # Tihs is a fake submission event. It will be replace by a
  # real one on import from the datastore.
  def application_submitted_item
    ApplicationHistoryItem.new(
      user_id: nil,
      user_name: 'Provider Name',
      timestamp: application.submitted_at,
      event_type: 'Application::Submitted'
    )
  end
end

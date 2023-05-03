class ApplicationHistory < ApplicationStruct
  EVENT_TYPES = [
    Assigning::AssignedToUser,
    Assigning::UnassignedFromUser,
    Assigning::ReassignedToUser,
    Reviewing::ApplicationReceived,
    Reviewing::SentBack,
    Reviewing::Completed,
    Reviewing::MarkedAsReady
  ].freeze

  attribute :application, Types.Instance(CrimeApplication)

  def items
    @items ||= load_from_events
  end

  private

  def load_from_events
    RailsEventStore::Projection
      .from_stream(streams)
      .init(-> { [] })
      .when(
        ApplicationHistory::EVENT_TYPES,
        lambda { |state, event|
          state << ApplicationHistoryItem.from_event(event, application)
        }
      ).run(Rails.application.config.event_store).sort_by(&:timestamp).reverse
  end

  def streams
    ["Assigning$#{application.id}", "Reviewing$#{application.id}"]
  end
end

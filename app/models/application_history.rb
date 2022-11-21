# READ MODEL
class ApplicationHistory < ApplicationStruct
  attribute :application, Types.Instance(CrimeApplication)

  def events
    @events ||= load_events
  end

  private

  def load_events
    RailsEventStore::Projection
      .from_stream("Assigning$#{application.id}")
      .init(-> { [application_submitted_event] })
      .when(
        [Assigning::AssignedToUser, Assigning::UnassignedFromSelf],
        ->(state, event) { state << ApplicationHistoryEvent.from_event(event) }
      ).run(Rails.application.config.event_store).reverse
  end

  # NOTE: provider name is not yet availble in the data.
  def application_submitted_event
    ApplicationHistoryEvent.new(
      user_id: nil,
      user_name: 'Provider Name',
      timestamp: application.submission_date,
      event_type: 'Application::Submitted'
    )
  end
end

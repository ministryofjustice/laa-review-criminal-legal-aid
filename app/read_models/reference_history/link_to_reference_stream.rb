module ReferenceHistory
  class LinkToReferenceStream
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event)
      reference = reference_for(event)
      if reference.blank?
        Rails.logger.warn(
          "ReferenceHistory::LinkToReferenceStream could not determine reference for event_id=#{event.event_id}"
        )
        return
      end

      @event_store.link(event.event_id, stream_name: ReferenceHistory.stream_name(reference))
    end

    private

    attr_reader :event_store

    def reference_for(event)
      ref = event.data[:reference]
      return ref if ref.present?

      # Assigning events do not have reference data so we derive application_id then look up the Review
      application_id = application_id_for(event)
      return if application_id.blank?

      Review.where(application_id:).limit(1).pick(:reference)
    end

    def application_id_for(event)
      # Reviewing events use :application_id
      return event.data[:application_id] if event.data.key?(:application_id)

      # Assigning events use :assignment_id
      return event.data[:assignment_id] if event.data.key?(:assignment_id)

      nil
    end
  end
end

module Allocating
  class CompetenciesSet < RailsEventStore::Event; end
  class WorkStreamNotFound < StandardError; end

  class << self
    def user_competencies(user_id)
      user_events(user_id).backward.first&.data&.[](:competencies)
    end

    def user_events(user_id)
      Rails.application.config.event_store.read.stream(stream_name(user_id))
    end

    def stream_name(user_id)
      "Allocating$#{user_id}"
    end
  end
end

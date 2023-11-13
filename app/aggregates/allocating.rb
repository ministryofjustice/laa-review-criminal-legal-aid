module Allocating
  class CompetenciesSet < RailsEventStore::Event; end

  class << self
    def user_competencies(user_id)
      Rails.application.config.event_store.read.stream(stream_name(user_id)).backward.first&.data&.[](:competencies)
    end

    def stream_name(user_id)
      "Allocating$#{user_id}"
    end
  end
end

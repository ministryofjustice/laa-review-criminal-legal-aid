module Deleting
  class Error < StandardError; end
  class AlreadyArchived < Error; end
  class AlreadySoftDeleted < Error; end

  class Event < RailsEventStore::Event; end
  class SoftDeleted < Event; end
  class Archived < Event; end

  class << self
    def already_archived?(reference)
      stream_name = ReferenceHistory.stream_name(reference)
      Rails.configuration.event_store
           .read
           .stream(stream_name)
           .of_type([Deleting::Archived])
           .to_a
           .any?
    end

    def already_soft_deleted?(reference)
      stream_name = ReferenceHistory.stream_name(reference)
      Rails.configuration.event_store
           .read
           .stream(stream_name)
           .of_type([Deleting::SoftDeleted])
           .to_a
           .any?
    end
  end
end

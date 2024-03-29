module Reviewing
  class Command < Dry::Struct
    attribute :application_id, Types::Uuid

    def with_review(&block)
      repository.with_aggregate(
        Review.new(application_id), stream_name, &block
      )
    end

    private

    def repository
      @repository ||= AggregateRoot::Repository.new(
        Rails.configuration.event_store
      )
    end

    def stream_name
      Reviewing.stream_name(application_id)
    end

    class << self
      def call(args)
        new(args).call
      end
    end
  end
end

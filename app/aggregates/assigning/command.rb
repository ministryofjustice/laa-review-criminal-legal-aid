module Assigning
  class Command < Dry::Struct
    attribute :assignment_id, Types::Uuid

    def with_assignment(&block)
      repository.with_aggregate(
        Assignment.new(assignment_id), stream_name, &block
      )
    end

    private

    def repository
      @repository ||= AggregateRoot::Repository.new(
        Rails.configuration.event_store
      )
    end

    def stream_name
      "Assigning$#{assignment_id}"
    end

    class << self
      def call(args)
        new(args).call
      end
    end
  end
end

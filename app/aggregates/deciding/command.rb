module Deciding
  class Command < Dry::Struct
    attribute :decision_id, Types::Uuid

    def with_decision(&block)
      repository.with_aggregate(
        Decision.new(decision_id),
        stream_name,
        &block
      )
    end

    private

    def repository
      @repository ||= AggregateRoot::Repository.new(
        Rails.configuration.event_store
      )
    end

    def stream_name
      Deciding.stream_name(decision_id)
    end

    class << self
      def call(args)
        new(args).call
      end
    end
  end
end

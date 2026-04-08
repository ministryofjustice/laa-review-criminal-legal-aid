module Reviewing
  class Command < Dry::Struct
    attribute :application_id, Types::Uuid

    def with_review(user_id: nil, &block)
      raise UnexpectedAssignee if user_id.present? && unexpected_assignee?(user_id)

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

    def unexpected_assignee?(user_id)
      !Assigning::LoadAssignment.call(assignment_id: application_id).assigned_to?(user_id)
    end

    class << self
      def call(args)
        new(args).call
      end
    end
  end
end

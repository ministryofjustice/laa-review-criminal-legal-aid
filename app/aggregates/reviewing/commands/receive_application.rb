module Reviewing
  class ReceiveApplication < Command
    attribute :application_id, Types::Uuid
    attribute :submitted_at, Types::DateTime
    attribute? :parent_id, Types::Uuid.optional
    attribute :work_stream, Types::WorkStreamType
    attribute :application_type, Types::ApplicationType
    attribute? :correlation_id, Types::Uuid.optional
    attribute? :causation_id, Types::Uuid.optional

    def call
      with_review do |review|
        review.receive_application(submitted_at:, application_type:, parent_id:, work_stream:)
      end

      return unless supersedes?

      # Supersede parent application if one exists
      Reviewing::Supersede.call(
        application_id: parent_id,
        superseded_at: submitted_at,
        superseded_by: application_id
      )
    end

    def supersedes?
      parent_id && application_type == Types::ApplicationType['initial']
    end
  end
end

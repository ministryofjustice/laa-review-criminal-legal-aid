module Reviewing
  class ReceiveApplication < Command
    attribute :application_id, Types::Uuid
    attribute :submitted_at, Types::DateTime
    attribute? :parent_id, Types::Uuid.optional
    attribute :work_stream, Types::WorkStreamType
    attribute? :correlation_id, Types::Uuid.optional
    attribute? :causation_id, Types::Uuid.optional

    def call
      with_review do |review|
        review.receive_application(submitted_at:, parent_id:, work_stream:)
      end

      return unless parent_id

      # Supersede parent application if one exists
      Reviewing::Supersede.call(
        application_id: parent_id,
        superseded_at: submitted_at,
        superseded_by: application_id
      )
    end
  end
end

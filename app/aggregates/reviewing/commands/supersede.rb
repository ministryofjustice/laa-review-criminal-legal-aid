module Reviewing
  class Supersede < Command
    attribute :application_id, Types::Uuid
    attribute :superseded_at, Types::DateTime
    attribute :superseded_by, Types::Uuid

    def call
      with_review do |review|
        review.supersede(superseded_at:, superseded_by:)
      end
    end
  end
end

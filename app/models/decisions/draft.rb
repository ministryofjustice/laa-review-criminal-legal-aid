require 'laa_crime_schemas'
module Decisions
  class Draft < LaaCrimeSchemas::Structs::Decision
    attribute? :funding_decision, Types::Nil | Types::FundingDecision
    attribute? :reference, Types::Nil | Types::Integer
    attribute? :decision_id, Types::Nil | Types::Integer | Types::Uuid
    attribute? :application_id, Types::Uuid
    attribute? :maat_id, Types::Integer.optional
    attribute? :case_id, Types::String.optional

    def to_param
      { crime_application_id: application_id, decision_id: decision_id }
    end

    def complete?
      funding_decision.present?
    end

    def checksum
      Digest::MD5.hexdigest(to_json)
    end

    class << self
      def build(aggregate)
        new(
          maat_id: aggregate.maat_id,
          case_id: aggregate.case_id,
          application_id: aggregate.application_id,
          reference: aggregate.reference,
          interests_of_justice: aggregate.interests_of_justice,
          means: aggregate.means,
          funding_decision: aggregate.funding_decision,
          comment: aggregate.comment,
          decision_id: aggregate.decision_id,
          checksum: aggregate.checksum
        )
      end
    end
  end
end

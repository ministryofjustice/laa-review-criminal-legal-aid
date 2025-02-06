require 'laa_crime_schemas'
module Decisions
  class Draft < LaaCrimeSchemas::Structs::Decision
    attribute? :decision_id, Types::Nil | Types::Integer | Types::Uuid
    attribute? :application_id, Types::Uuid

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
      def build(aggregate) # rubocop:disable Metrics/MethodLength
        new(
          application_id: aggregate.application_id,
          case_id: aggregate.case_id,
          checksum: aggregate.checksum,
          comment: aggregate.comment,
          assessment_rules: aggregate.assessment_rules,
          decision_id: aggregate.decision_id,
          funding_decision: aggregate.funding_decision,
          interests_of_justice: aggregate.interests_of_justice,
          maat_id: aggregate.maat_id,
          means: aggregate.means,
          overall_result: aggregate.overall_result,
          reference: aggregate.reference
        )
      end
    end
  end
end

module Maat
  class Decision < Dry::Struct
    attribute :reference, Types::Integer.optional
    attribute :maat_id, Types::Integer
    attribute :interests_of_justice, Types::InterestsOfJusticeDecision
    attribute :means, Types::MeansDecision
    attribute :funding_decision, Types::FundingDecisionResult
    attribute? :comment, Types::String.optional

    class << self
      def build(response)
        new(
          reference: response['usn'],
          maat_id: response['maat_ref'],
          case_id: response['case_id'],
          funding_decision: funding_decision(response['funding_decision']),
          interests_of_justice: interests_of_justice(response),
          means: means(response)
        )
      end

      def funding_decision(maat_value)
        return nil if maat_value.blank?

        maat_value.downcase
      end

      def interests_of_justice(response)
        return {} if response['ioj_result'].blank?

        {
          result: response['ioj_result'].downcase,
          assessed_by: response['ioj_assessor_name'],
          assessed_on: response['app_created_date']
        }
      end

      def means(response)
        return {} if response['means_result'].blank?

        {
          result: response['means_result'].downcase,
          assessed_by: response['means_assessor_name'],
          assessed_on: response['date_means_created']
        }
      end
    end
  end
end

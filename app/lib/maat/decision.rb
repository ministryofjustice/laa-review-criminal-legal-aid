module Maat
  class Decision < Dry::Struct
    attribute :reference, Types::Integer.optional
    attribute :maat_id, Types::Integer
    attribute? :case_id, Types::String.optional
    attribute :interests_of_justice, Types::InterestsOfJusticeDecision.optional
    attribute :means, Types::MeansDecision.optional
    attribute :funding_decision, Types::FundingDecisionResult.optional
    attribute? :comment, Types::String.optional

    def checksum
      Digest::MD5.hexdigest(to_json)
    end

    class << self
      def build(response)
        Rails.logger.debug response
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
        return nil if response['ioj_result'].blank?

        {
          result: response['ioj_result'].downcase,
          assessed_by: response['ioj_assessor_name'],
          assessed_on: response['app_created_date']
        }
      end

      def means(response)
        return nil if response['means_result'].blank?

        {
          result: response['means_result'].downcase,
          assessed_by: response['means_assessor_name'],
          assessed_on: response['date_means_created']
        }
      end
    end
  end
end

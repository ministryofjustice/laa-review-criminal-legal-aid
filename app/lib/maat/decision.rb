module Maat
  class Decision < LaaCrimeSchemas::Structs::Decision
    attribute :maat_id, Types::Integer
    attribute? :case_id, Types::String.optional
    attribute :funding_decision, Types::FundingDecisionResult.optional

    def checksum
      Digest::MD5.hexdigest(to_json)
    end

    alias decision_id maat_id

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
        return nil if response['ioj_result'].blank?

        {
          result: response['ioj_result'].downcase,
          details: response['ioj_reason'],
          assessed_by: response['ioj_assessor_name'],
          assessed_on: response['app_created_date']
        }
      end

      def result(maat_result); end

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

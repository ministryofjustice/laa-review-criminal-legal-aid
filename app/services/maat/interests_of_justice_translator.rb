module Maat
  class InterestsOfJusticeTranslator
    def initialize(maat_decision:)
      @maat_decision = maat_decision
    end

    class << self
      def translate(maat_decision:)
        new(maat_decision:).translate
      end
    end

    def translate
      return nil unless result

      LaaCrimeSchemas::Structs::TestResult.new(
        result:, assessed_by:, assessed_on:, details:
      )
    end

    private

    def assessed_on
      maat_decision.app_created_date
    end

    def assessed_by
      maat_decision.ioj_assessor_name
    end

    def details
      maat_decision.ioj_reason
    end

    def result
      InterestsOfJusticeResultTranslator.translate(maat_result)
    end

    def maat_result
      maat_decision.ioj_appeal_result.presence || maat_decision.ioj_result
    end

    attr_reader :maat_decision
  end
end

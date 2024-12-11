module Maat
  class MeansTranslator
    def initialize(maat_decision:)
      @maat_decision = maat_decision
    end

    def translate
      return nil unless result

      LaaCrimeSchemas::Structs::TestResult.new(
        result:, assessed_by:, assessed_on:
      )
    end

    class << self
      def translate(maat_decision)
        new(maat_decision:).translate
      end
    end

    private

    attr_reader :maat_decision

    def assessed_on
      if passport_result_most_recent?
        maat_decision.date_passport_created
      else
        maat_decision.date_means_created
      end
    end

    def assessed_by
      if passport_result_most_recent?
        maat_decision.passport_assessor_name
      else
        maat_decision.means_assessor_name
      end
    end

    def result
      Maat::MeansResultTranslator.translate(maat_result)
    end

    def maat_result
      if passport_result_most_recent?
        maat_decision.passport_result
      else
        maat_decision.means_result
      end
    end

    def passport_result_most_recent?
      return false if maat_decision.date_passport_created.blank?
      return true if maat_decision.date_means_created.blank?

      maat_decision.date_passport_created > maat_decision.date_means_created
    end
  end
end

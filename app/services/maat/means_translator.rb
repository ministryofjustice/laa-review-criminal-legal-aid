module Maat
  class MeansTranslator
    def initialize(maat_decision:, court_type:)
      @maat_decision = maat_decision
      @court_type = court_type
    end

    def translate
      return nil unless result

      LaaCrimeSchemas::Structs::TestResult.new(
        result:, assessed_by:, assessed_on:
      )
    end

    class << self
      def translate(maat_decision, court_type:)
        new(maat_decision:, court_type:).translate
      end
    end

    private

    attr_reader :maat_decision, :court_type

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
      return passport_result if passport_result_most_recent?
      return crown_court_result if court_type == 'crown'

      MagistratesMeansResultTranslator.translate(maat_decision.means_result)
    end

    def passport_result
      PassportMeansResultTranslator.translate(
        maat_decision.passport_result
      )
    end

    def crown_court_result
      CrownCourtMeansResultTranslator.translate(
        maat_decision.means_result
      )
    end

    def passport_result_most_recent?
      return false if maat_decision.date_passport_created.blank?
      return true if maat_decision.date_means_created.blank?

      maat_decision.date_passport_created > maat_decision.date_means_created
    end
  end
end

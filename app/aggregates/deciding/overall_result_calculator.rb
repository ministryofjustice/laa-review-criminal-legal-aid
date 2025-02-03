module Deciding
  class OverallResultCalculator
    def initialize(decision)
      @decision = decision
    end

    def calculate
      return unless funding_decision

      Types::OverallResult[
        [funding_decision, qualification].compact.join('_')
      ]
    end

    private

    attr_reader :decision

    def qualification
      return refusal_qualification if refused?

      grant_qualification if granted?
    end

    def refusal_qualification
      return 'failed_ioj_and_means' if failed_means? && failed_ioj?
      return 'failed_ioj' if failed_ioj?

      'failed_means' if failed_means?
    end

    def grant_qualification
      return 'failed_means' if failed_means?

      'with_contribution' if with_contribution?
    end

    delegate :funding_decision, to: :decision

    def failed_means?
      decision.means&.result == 'failed'
    end

    def granted?
      funding_decision == 'granted'
    end

    def refused?
      funding_decision == 'refused'
    end

    def with_contribution?
      decision.means&.result == 'passed_with_contribution'
    end

    def failed_ioj?
      decision.interests_of_justice&.result == 'failed'
    end
  end
end

module Deciding
  class SetFundingDecision < Command
    attribute :user_id, Types::Uuid
    attribute :funding_decision, Types::FundingDecision

    def call
      with_decision do |decision|
        decision.set_funding_decision(
          user_id:, funding_decision:, overall_result:
        )
      end
    end

    private

    # Store the overall results string as it would appear in eForms.
    def overall_result
      Maat::OverallResultTranslator.translate(maat_funding_decision)
    end

    # Crime Review only creates decisions for Non-Means applications.
    # If a funding decision is refused, we can infer that the application
    # failed the IoJ test. Consequently, the MAAT funding decision
    # should be recorded as FAILIOJ.
    def maat_funding_decision
      case funding_decision
      when /granted/
        'GRANTED'
      when /refused/
        'FAILIOJ'
      end
    end
  end
end

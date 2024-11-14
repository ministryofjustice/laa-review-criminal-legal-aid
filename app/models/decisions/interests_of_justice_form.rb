module Decisions
  class InterestsOfJusticeForm
    include DecisionFormPersistance

    attribute :result, :string
    attribute :details, :string
    attribute :assessed_by, :string
    attribute :assessed_on, :date

    validates :result, inclusion: { in: :possible_results }
    validates :details, :assessed_by, presence: true
    validates :assessed_on, presence: true

    def possible_results
      Types::InterestsOfJusticeResult.values
    end

    class << self
      def build(application:, decision:)
        ioj_attrs = decision.interests_of_justice.to_h

        new(
          **ioj_attrs,
          application: application,
          decision_id: decision.decision_id
        )
      end
    end

    private

    def command_class
      Deciding::SetInterestsOfJustice
    end
  end
end

module Decisions
  class MaatDecisionForm
    include DecisionFormPersistance

    attribute :maat_id, :string

    private

    def command_class
      Deciding::SetComment
    end
  end
end

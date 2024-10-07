module Decisions
  class MaatIdForm
    include DecisionFormPersistance

    attribute :maat_id, :string

    private

    def command_class
      Deciding::SetComment
    end
  end
end

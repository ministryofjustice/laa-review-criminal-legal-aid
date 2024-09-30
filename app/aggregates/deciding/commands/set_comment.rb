module Deciding
  class SetComment < Command
    attribute :user_id, Types::Uuid
    attribute :comment, Types::Params::String

    def call
      with_decision do |decision|
        decision.set_comment(user_id:, comment:)
      end
    end
  end
end

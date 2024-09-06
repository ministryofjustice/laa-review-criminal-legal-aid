module Decisions
  class Outcome < ApplicationStruct
    OUTCOMES = [:failed_interests_of_justice, :granted].freeze

    attribute? :outcome, Types::Nil | Types::String
    attribute? :reason, Types::Nil | Types::String

    validates :outcome, presence: true
  end
end

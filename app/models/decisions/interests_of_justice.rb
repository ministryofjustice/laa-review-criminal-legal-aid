module Decisions
  class InterestsOfJustice < ApplicationStruct
    attribute :result, Types::InterestsOfJusticeResult
    attribute :details, Types::String
    attribute :assessed_by, Types::String
    attribute :assessed_on, Types::Date
  end
end

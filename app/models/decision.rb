class Decision < ApplicationStruct
  attribute? :interests_of_justice, Decisions::InterestsOfJustice
  attribute? :result, Types::String
  attribute? :details, Types::String
  attribute? :decision_id, Types::Uuid
end

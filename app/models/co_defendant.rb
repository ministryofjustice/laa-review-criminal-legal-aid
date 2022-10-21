class CoDefendant < ApplicationStruct
  attribute :first_name, Types::String
  attribute :last_name, Types::String
  attribute :conflict_of_interest, Types::Bool
end

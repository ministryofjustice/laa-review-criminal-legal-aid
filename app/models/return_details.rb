class ReturnDetails < ApplicationStruct
  RETURN_REASONS = Types::RETURN_REASONS

  attribute? :reason, Types::Nil | Types::String
  attribute? :details, Types::Nil | Types::String

  validates :details, length: { minimum: 10 }
  validates :reason, inclusion: { in: RETURN_REASONS }
end

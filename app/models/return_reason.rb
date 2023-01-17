class ReturnReason < ApplicationStruct
  attribute? :type, Types::Nil | Types::String
  attribute? :details, Types::Nil | Types::String

  validates_with SchemaValidator, schema: Types::ReturnReasonSchema
end

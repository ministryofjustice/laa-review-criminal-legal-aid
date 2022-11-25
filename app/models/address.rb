class Address < ApplicationStruct
  attribute :address_line_one, Types::String
  attribute :address_line_two, Types::String
  attribute :county, Types::String
  attribute :postcode, Types::String
end


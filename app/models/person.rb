class Person < ApplicationStruct
  attribute :first_name, Types::String
  attribute :last_name, Types::String
  attribute :address, Address
  attribute :telephone_number, Types::PhoneNumber
  attribute? :national_insurance_number, Types::String
  attribute? :date_of_birth, Types::JSON::Date
  attribute? :correspondence_address
end

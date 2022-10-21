class Offence < ApplicationStruct
  attribute :offence_class, Types::String
  attribute :date, Types::Date
  attribute :name, Types::String

  transform_keys do |key|
    key = key.to_sym
    case key
    when :class
      :offence_class
    else
      key
    end
  end
end

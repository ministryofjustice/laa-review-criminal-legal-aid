# TODO: share types via gem
module Types
  include Dry.Types()

  MeansType = Types::Symbol.default(:passported).enum(
    *%i[passported]
  )

  PhoneNumber = Types::String
end

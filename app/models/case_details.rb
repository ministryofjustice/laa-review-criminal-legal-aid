class CaseDetails < ApplicationStruct
  attribute :case_type, Types::String
  attribute? :court_type, Types::String
  attribute :co_defendants, Types::Array.of(CoDefendant)
  attribute :offences, Types::Array.of(Offence)
  attribute :urn, Types::String
end

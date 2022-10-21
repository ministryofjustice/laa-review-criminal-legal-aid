class CaseDetails < ApplicationStruct
  attribute :case_type, Types::CaseType
  attribute :hearing_court_name, Types::String
  attribute :hearing_date, Types::Date
  attribute :co_defendants, Types::Array.of(CoDefendant)
  attribute :offences, Types::Array.of(Offence)
  attribute :urn, Types::String
end

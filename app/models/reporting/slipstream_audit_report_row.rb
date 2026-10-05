module Reporting
  class SlipstreamAuditReportRow < ApplicationStruct
    attribute :reference, Types::Integer
    attribute :office_code, Types::Params::Nil | Types::String
    attribute :selection_reason, Types::Params::Nil | Types::String
    attribute :sample_rate, Types::Integer
    attribute :sampled_at, Types::DateTime
    attribute :submitted_at, Types::DateTime
    attribute :maat_reference, Types::Params::Nil | Types::Integer
    attribute :ioj_outcome, Types::Params::Nil | Types::String
    attribute :offences, Types::Array.of(Types::Hash)

    def offence_names
      offences.pluck('name')
    end
  end
end

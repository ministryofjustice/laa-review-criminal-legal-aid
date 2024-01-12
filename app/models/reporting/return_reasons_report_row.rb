module Reporting
  class ReturnReasonsReportRow < ApplicationStruct
    attribute :office_code, Types::String
    attribute :provider_name, Types::String
    attribute :reference, Types::Integer
    attribute :resource_id, Types::Uuid
    attribute :return_details, Types::String
    attribute :return_reason, Types::ReturnReason
    attribute :reviewed_at, Types::DateTime

    def reviewer_id
      @reviewer_id ||= Review.reviewer_id_for(resource_id)
    end

    def closed_by
      User.name_for(reviewer_id)
    end

    # TODO: make dynamic when other means_tested values are understood
    def means_tested
      'passported'
    end
  end
end

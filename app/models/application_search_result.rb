class ApplicationSearchResult < ApplicationStruct
  attribute :applicant_name, Types::String
  attribute :submitted_at, Types::DateTime
  attribute :reference, Types::Integer
  attribute :resource_id, Types::Uuid
  attribute :status, Types::String
  attribute :work_stream, Types::WorkStreamType
  attribute :office_code, Types::String
  attribute? :application_type, Types::ApplicationType
  attribute? :case_type, Types::CaseType.optional
  attribute? :parent_id, Types::Uuid.optional

  include Assignable
  include Reviewable

  alias id resource_id

  def days_passed
    @days_passed ||= business_day.age_in_business_days
  end

  def caseworker_name
    reviewer_name || assignee_name
  end

  def to_param
    id
  end
end

class ApplicationSearchResult < ApplicationStruct
  attribute :applicant_name, Types::String
  attribute :submitted_at, Types::DateTime
  attribute :reference, Types::Integer
  attribute :resource_id, Types::Uuid
  attribute :status, Types::String
  attribute? :parent_id, Types::Uuid.optional

  include Assignable
  include Reviewable

  alias id resource_id

  def days_passed
    Calendar.new.business_days_between(submitted_at, Time.zone.now.to_date)
  end

  def caseworker_name
    reviewer_name || assignee_name
  end

  def to_param
    id
  end
end

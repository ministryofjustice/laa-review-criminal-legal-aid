class ApplicationSearchResult < ApplicationStruct
  attribute :applicant_name, Types::String
  attribute :submitted_at, Types::DateTime
  attribute :reference, Types::Integer
  attribute :resource_id, Types::Uuid
  attribute :status, Types::String

  alias id resource_id

  def days_passed
    Rational(time_passed, 1.day).floor
  end

  def common_platform?
    true
  end

  def current_assignment
    @current_assignment ||= CurrentAssignment.find_by(assignment_id: id)
  end

  # TODO: Convert to working days
  def time_passed
    Time.zone.now - submitted_at
  end
end

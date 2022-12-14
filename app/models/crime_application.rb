require 'laa_crime_schemas'

class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
  include ApiResource

  def applicant_name
    applicant.full_name
  end

  delegate :date_of_birth, to: :applicant, prefix: true

  def means_type
    :passported
  end

  def common_platform?
    true
  end

  def days_passed
    Rational(time_passed, 1.day).floor
  end

  def current_assignment
    @current_assignment ||= CurrentAssignment.where(assignment_id: id).first
  end

  def history
    @history ||= ApplicationHistory.new(application: self)
  end

  private

  # TODO: Convert to working days
  def time_passed
    Time.zone.now - submitted_at
  end

  # TODO: Convert to working days
  def applicant
    client_details.applicant
  end
end

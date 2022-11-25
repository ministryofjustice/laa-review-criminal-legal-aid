require 'laa_crime_schemas'

class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
  include ApiResource

  # attribute :id, Types::String
  # attribute :reference, Types::String
  # attribute :application_type, Types::String
  # attribute :application_start_date, Types::JSON::DateTime
  # attribute :submission_date, Types::JSON::DateTime

  # attribute :client_details, ClientDetails
  # attribute :case_details, CaseDetails
  # attribute :interests_of_justice, Types::Array.of(InterestOfJustice)

  def applicant_name
    [applicant.first_name, applicant.last_name].join ' '
  end

  def applicant_date_of_birth
    applicant.date_of_birth
  end

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
    @current_assignment ||= CurrentAssignment.new(crime_application_id: id)
  end

  def history
    @history ||= ApplicationHistory.new(application: self)
  end

  private

  def time_passed
    Time.zone.now - submitted_at
  end

  def applicant
    client_details.applicant
  end
end

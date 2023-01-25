require 'laa_crime_schemas'

class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
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

  def current_assignment
    @current_assignment ||= Assigning::LoadAssignment.new(
      assignment_id: id
    ).call
  end

  def history
    @history ||= ApplicationHistory.new(application: self)
  end

  def to_param
    id
  end

  class << self
    def find(id)
      resource = DatastoreApi::Requests::GetApplication.new(
        application_id: id
      ).call

      new(resource)
    end
  end

  private

  # TODO: Convert to working days
  def applicant
    client_details.applicant
  end
end

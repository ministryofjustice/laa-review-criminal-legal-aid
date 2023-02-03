require 'laa_crime_schemas'

class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
  include Assignable
  include Reviewable

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

  def history
    @history ||= ApplicationHistory.new(application: self)
  end

  def to_param
    id
  end

  def reviewable_by?(user_id)
    !reviewed? && assigned_to?(user_id)
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

  def applicant
    client_details.applicant
  end
end

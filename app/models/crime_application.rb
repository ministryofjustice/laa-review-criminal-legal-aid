require 'laa_crime_schemas'

class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
  include Assignable
  include Reviewable

  def applicant_name
    applicant.full_name
  end

  def legal_rep_name
    [
      provider_details.legal_rep_first_name,
      provider_details.legal_rep_last_name
    ].join ' '
  end

  delegate :date_of_birth, to: :applicant, prefix: true

  def means_type
    :passported
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

  def status?(status)
    review_status == status
  end

  class << self
    def find(id)
      application = new(
        DatastoreApi::Requests::GetApplication.new(
          application_id: id
        ).call
      )

      # Receive the application if it has not yet been received.
      #
      # In production, Review is notified of new applications via SNS,
      # and, as such, the application should be received by this point.
      #
      # receive_if_required! is user here to:
      # 1. support other environments that do not have SNS set up,
      # 2. act as a failsafe should an application be returned by
      # the datastore before its SNS event message has been processed.

      application.receive_if_required!
    end
  end

  def parent
    return nil if parent_id.nil?
    return nil if parent_id == id

    @parent ||= CrimeApplication.find(parent_id)
  end

  def all_histories
    return @all_histories if @all_histories

    histories = [history]
    histories += parent.all_histories if parent

    @all_histories = histories
  end

  private

  def applicant
    client_details.applicant
  end
end

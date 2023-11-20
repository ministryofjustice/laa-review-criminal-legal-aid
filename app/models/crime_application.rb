require 'laa_crime_schemas'

class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
  include Assignable
  include Reviewable

  def supporting_evidence
    super.map { |document| Document.new(document.attributes) }
  end

  def legal_rep_name
    [
      provider_details.legal_rep_first_name,
      provider_details.legal_rep_last_name
    ].join ' '
  end

  def means_passported?
    !means_passport.empty?
  end

  def means_passported_on_age?
    means_passport.include?(Types::MeansPassportType['on_age_under18'])
  end

  def relevant_ioj_passport
    # Being under 18 trumps any other interest of justice
    if ioj_passport.include?('on_age_under18')
      'on_age_under18'
    elsif ioj_passport == ['on_offence']
      'on_offence'
    end
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

  def superseding_history_item
    return nil unless superseded_by

    ApplicationHistoryItem.new(
      user_name: legal_rep_name,
      event_type: 'Reviewing::Superseded',
      timestamp: superseded_at,
      event_data: { superseded_by: }
    )
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

  def latest_application_id
    crime_application = self

    until crime_application.superseded_by.nil?
      crime_application = CrimeApplication.find(crime_application.superseded_by)
    end

    crime_application.id
  end

  def all_histories
    return @all_histories if @all_histories

    histories = [history]
    histories += parent.all_histories if parent

    @all_histories = histories
  end

  def case_details
    @case_details ||= CaseDetailsPresenter.present(self[:case_details])
  end

  def applicant
    @applicant ||= ApplicantPresenter.present(self[:client_details][:applicant])
  end
end

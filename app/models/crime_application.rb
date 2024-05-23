require 'laa_crime_schemas'

class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication # rubocop:disable Metrics/ClassLength
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

  def means_passported_on_benefit?
    means_passport.include?(Types::MeansPassportType['on_benefit_check'])
  end

  def not_means_tested?
    means_passport.include?(Types::MeansPassportType['on_not_means_tested'])
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

  def submission_type
    return 'resubmission' if parent_id && application_type == 'initial'

    application_type
  end

  def work_stream
    @work_stream ||= WorkStream.new(attributes[:work_stream])
  end

  class << self
    def find(id)
      application = new(
        DatastoreApi::Requests::GetApplication.new(application_id: id).call
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
    return if pse?

    @case_details ||= CaseDetailsPresenter.present(self[:case_details])
  end

  def applicant
    @applicant ||= ApplicantPresenter.present(self[:client_details][:applicant])
  end

  def dependants
    @dependants ||= DependantsPresenter.present(self[:means_details].income_details&.dependants)
  end

  def income_benefits
    @income_benefits ||= IncomeBenefitsPresenter.present(self[:means_details].income_details&.income_benefits)
  end

  def outgoings_details
    @outgoings_details ||= OutgoingsDetailsPresenter.present(self[:means_details].outgoings_details)
  end

  def income_payments
    @income_payments ||= IncomePaymentsPresenter.present(self[:means_details].income_details&.income_payments)
  end

  def outgoing_payments
    @outgoing_payments ||= OutgoingPaymentsPresenter.present(self[:means_details].outgoings_details&.outgoings)
  end

  def pse?
    application_type == Types::ApplicationType['post_submission_evidence']
  end

  def appeal_no_changes?
    case_details&.case_type == Types::CaseType['appeal_to_crown_court'] &&
      case_details&.appeal_reference_number.present?
  end

  def last_jsa_appointment_date?
    client_details.applicant.benefit_type == 'jsa' && client_details.applicant.last_jsa_appointment_date.present?
  end

  # TODO: ensure evidence_details always has a struct for PSE view?
  def evidence_details
    struct =
      if attributes[:evidence_details].blank?
        LaaCrimeSchemas::Structs::EvidenceDetails.new
      else
        self[:evidence_details]
      end

    @evidence_details ||= EvidenceDetailsPresenter.present(struct)
  end

  def display_benefit_section?
    !applicant.benefit_check_attributes_not_set? || means_passported_on_benefit?
  end
end

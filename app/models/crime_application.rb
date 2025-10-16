require 'laa_crime_schemas'

class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication # rubocop:disable Metrics/ClassLength
  include Assignable
  include Reviewable
  include TypeOfApplication

  PRE_CIFC_MAAT_ID = 'pre_cifc_maat_id'.freeze
  PRE_CIFC_USN = 'pre_cifc_usn'.freeze

  def supporting_evidence
    super.map { |document| Document.new(document.attributes) }
  end

  def legal_rep_name
    [
      provider_details.legal_rep_first_name,
      provider_details.legal_rep_last_name
    ].join ' '
  end

  def applicant_name
    return I18n.t('values.deleted_applicant_name') if erased?

    applicant&.full_name
  end

  def means_passported?
    !means_passport.empty?
  end

  def means_passported_on_age?
    means_passport.include?(Types::MeansPassportType['on_age_under18'])
  end

  def not_means_tested?
    is_means_tested == 'no'
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

  def decisions
    return draft_decisions unless status?(::Types::ReviewState[:completed])

    super
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

  def erased?
    true
  end

  def client_details
    @client_details ||= ClientDetailsPresenter.present(self[:client_details])
  end

  def applicant
    @applicant ||= PersonPresenter.present(self[:client_details][:applicant])
  end

  def partner
    @partner ||= PersonPresenter.present(self[:client_details].partner)
  end

  def dependants
    @dependants ||= DependantsPresenter.present(self[:means_details].income_details&.dependants)
  end

  def employments
    self[:means_details].income_details.employments
  end

  def applicant_employments
    @applicant_employments ||= employments.select { |e| e.ownership_type == 'applicant' }
  end

  def partner_employments
    @partner_employments ||= employments.select { |e| e.ownership_type == 'partner' }
  end

  def businesses
    self[:means_details].income_details.businesses
  end

  def applicant_businesses
    @applicant_businesses ||= businesses.select { |e| e.ownership_type == 'applicant' }
  end

  def partner_businesses
    @partner_businesses ||= businesses.select { |e| e.ownership_type == 'partner' }
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

  def date_stamp_context
    @date_stamp_context ||= DateStampContextPresenter.present(DateStampContext.new(self))
  end

  def last_jsa_appointment_date?(person)
    person.benefit_type == 'jsa' && person.last_jsa_appointment_date.present?
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

  def maat_id_selected?
    pre_cifc_reference_number == PRE_CIFC_MAAT_ID
  end

  def usn_selected?
    pre_cifc_reference_number == PRE_CIFC_USN
  end

  def decisions_pending?
    decisions.present? && !status?(::Types::ReviewState[:completed])
  end
end

require 'laa_crime_schemas'

class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
  include Assignable
  include Reviewable

  def applicant_name
    applicant.full_name
  end

  def formatted_applicant_nino
    return if applicant.nino.nil?

    # Remove all spaces
    formatted_nino = applicant.nino.gsub(/\s+/, '').upcase
    [2, 5, 8, 11].each { |i| formatted_nino.insert i, ' ' } if formatted_nino.length == 9
    formatted_nino
  end

  def formatted_applicant_telephone_number
    return if applicant.telephone_number.nil?

    format_telephone_number(applicant.telephone_number)
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

  # NOTE: This code is intended for temporary use during user research on the
  # staging environment from 3-4 May. The code is not part of the final
  # implementation and should not be used in production.
  #
  # In production, the events stream will provide up-to-date events. However,
  # as the supserseding events are not available on the staging data user for
  # user testing, we are artificially generating the events for testing purposes only.

  # TODO: remove after 4 May
  def superseding_history_item
    return nil unless superseded_by

    ApplicationHistoryItem.new(
      user_name: legal_rep_name,
      event_type: 'Reviewing::Superseded',
      timestamp: superseded_at,
      event_data: { superseded_by: }
    )
  end

  # TODO: remove after 4 May
  def superseded?
    superseded_by.present?
  end

  # TODO: remove after 4 May
  def superseding_review
    @superseding_review ||= Review.find_by(parent_id: id)
  end

  # TODO: remove after 4 May
  def superseded_by
    superseding_review&.application_id
  end

  # TODO: remove after 4 May
  def superseded_at
    superseding_review&.submitted_at
  end
  # END user research temporary code

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

  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
  def format_telephone_number(number)
    # Remove all spaces
    formatted_tel = number.gsub(/\s+/, '')

    case formatted_tel
    when /\A07\d{9}\z/ # Mobile number with exactly 11 digits
      [5, 9].each { |i| formatted_tel.insert i, ' ' }
    when /\A\+447\d{9}\z/ #+44 mobile number format without initial 0
      [3, 8, 12].each { |i| formatted_tel.insert i, ' ' }
    when /\A\+4407\d{9}\z/ #+44 mobile number format with initial 0
      [3, 9, 13].each { |i| formatted_tel.insert i, ' ' }
    when /\A\+44\(0\)7\d{9}\z/ #+44 mobile numberformat with initial 0 in parentheses
      [3, 7, 12, 16].each { |i| formatted_tel.insert i, ' ' }
    else
      formatted_tel = applicant.telephone_number
    end

    formatted_tel
  end
  # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity
end

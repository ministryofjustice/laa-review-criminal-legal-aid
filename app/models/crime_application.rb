require 'laa_crime_schemas'

# rubocop:disable Metrics/ClassLength
class CrimeApplication < LaaCrimeSchemas::Structs::CrimeApplication
  include Assignable
  include Reviewable

  def file_type(filename)
    File.extname(filename).delete_prefix('.')
  end

  def applicant_name
    applicant.full_name
  end

  def formatted_applicant_nino
    return if applicant.nino.nil?

    applicant.nino
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

  delegate :date_of_birth, :benefit_type, to: :applicant, prefix: true

  def means_passported?
    !means_passport.empty?
  end

  def passporting_benefit?
    means_passport.include?(Types::MeansPassportType['on_benefit_check'])
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
    when /\A\+447\d{9}\z/ # +44 mobile number format without initial 0
      [3, 8, 12].each { |i| formatted_tel.insert i, ' ' }
    when /\A\+4407\d{9}\z/ # +44 mobile number format with initial 0
      [3, 9, 13].each { |i| formatted_tel.insert i, ' ' }
    when /\A\+44\(0\)7\d{9}\z/ # +44 mobile numberformat with initial 0 in parentheses
      [3, 7, 12, 16].each { |i| formatted_tel.insert i, ' ' }
    else
      formatted_tel = applicant.telephone_number
    end

    formatted_tel
  end
  # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity
end
# rubocop:enable Metrics/ClassLength

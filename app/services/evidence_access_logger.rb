class EvidenceAccessLogger
  EVIDENCE_VIEWED = 'evidence_viewed'.freeze
  EVIDENCE_DOWNLOADED = 'evidence_downloaded'.freeze

  def self.log_view(crime_application:, document:, current_user:)
    new(
      action: EVIDENCE_VIEWED,
      crime_application: crime_application,
      document: document,
      current_user: current_user
    ).log
  end

  def self.log_download(crime_application:, document:, current_user:)
    new(
      action: EVIDENCE_DOWNLOADED,
      crime_application: crime_application,
      document: document,
      current_user: current_user
    ).log
  end

  def initialize(action:, crime_application:, document:, current_user:)
    @action = action
    @crime_application = crime_application
    @document = document
    @current_user = current_user
  end

  def log
    Rails.logger.info(log_message)
  end

  private

  def log_message
    "#{@action} #{evidence_accessed.to_json}"
  end

  def evidence_accessed
    {
      application_id: @crime_application.id,
      caseworker_id: @current_user.id,
      caseworker_role: @current_user.role,
      assigned: @crime_application.assigned_to?(@current_user.id) ? 'assigned' : 'not_assigned',
      file_type: @document.content_type,
      timestamp: Time.current.iso8601
    }
  end
end

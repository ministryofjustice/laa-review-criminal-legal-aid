class EvidenceEmbedComponent < ViewComponent::Base
  include ActionView::Helpers
  include AppTextHelper

  def initialize(evidence:, crime_application:)
    @evidence = evidence
    @crime_application = crime_application
    super
  end

  private

  attr_reader :evidence, :crime_application

  def raw_path
    raw_crime_application_document_path(crime_application, evidence.s3_object_key)
  end

  def download_path
    download_crime_application_document_path(crime_application, evidence.s3_object_key)
  end

  def download_text
    sanitize(
      t(:download_file,
        scope: 'values',
        file_extension: evidence.file_extension,
        file_size: number_to_human_size(evidence.file_size))
    )
  end
end

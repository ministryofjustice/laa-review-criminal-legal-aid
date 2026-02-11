class SupportingEvidenceComponent < ViewComponent::Base
  include ActionView::Helpers
  include AppTextHelper

  def initialize(crime_application:)
    @crime_application = crime_application
    super
  end

  private

  attr_reader :crime_application

  def target
    FeatureFlags.view_evidence.enabled? ? '_blank' : ''
  end

  def link_text(evidence)
    if FeatureFlags.view_evidence.enabled?
      'View'
    else
      sanitize(
        t(:download_file,
          scope: 'values',
          file_extension: evidence.file_extension,
          file_size: number_to_human_size(evidence.file_size))
      )
    end
  end

  def download_path(evidence)
    download_documents_path(
      crime_application_id: crime_application.id,
      id: evidence.s3_object_key
    )
  end
end

class SupportingEvidenceComponent < ViewComponent::Base
  include ActionView::Helpers
  include AppTextHelper

  def initialize(crime_application:)
    @crime_application = crime_application
    super
  end

  private

  attr_reader :crime_application

  def view_link(evidence)
    govuk_link_to(
      view_link_text(evidence),
      documents_path(
        crime_application_id: crime_application.id,
        id: evidence.s3_object_key
      ),
      class: 'app-no-print',
      target: '_blank'
    )
  end

  def view_link_text(evidence)
    safe_join [
      t(:view_file, scope: 'values'),
      tag.span(sanitize(evidence.filename), class: 'govuk-visually-hidden')
    ], ' '
  end

  def download_link(evidence)
    govuk_link_to(
      download_text(evidence),
      download_documents_path(
        crime_application_id: crime_application.id,
        id: evidence.s3_object_key
      ),
      class: 'app-no-print'
    )
  end

  def download_text(evidence)
    sanitize(
      t(:download_file,
        scope: 'values',
        file_extension: evidence.file_extension,
        file_size: number_to_human_size(evidence.file_size))
    )
  end
end

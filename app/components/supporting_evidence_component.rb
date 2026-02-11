class SupportingEvidenceComponent < ViewComponent::Base
  include ActionView::Helpers
  include AppTextHelper

  def initialize(crime_application:)
    @crime_application = crime_application
    super
  end

  private

  attr_reader :crime_application

  def view_download_links(evidence)
    safe_join([view_link(evidence), download_link(evidence)].compact)
  end

  def view_link(evidence)
    return unless FeatureFlags.view_evidence.enabled?
    return unless evidence.viewable_inline?

    govuk_link_to(
      t(:view_file, scope: 'values'),
      documents_path(
        crime_application_id: crime_application.id,
        id: evidence.s3_object_key
      ),
      visually_hidden_text: evidence.filename,
      class: link_classes << 'govuk-!-font-weight-bold',
      target: '_blank'
    )
  end

  def download_link(evidence)
    govuk_link_to(
      download_text(evidence),
      download_documents_path(
        crime_application_id: crime_application.id,
        id: evidence.s3_object_key
      ),
      class: link_classes
    )
  end

  def link_classes
    %w[app-no-print govuk-summary-list__actions-list-item]
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

module Casework
  class DocumentsController < Casework::BaseController
    before_action :set_crime_application, :set_document

    rescue_from 'Datastore::Documents::DownloadError' do
      set_flash(:cannot_download_try_again, file_name: @document.filename, success: false)

      redirect_to crime_application_path(params[:crime_application_id])
    end

    def show
      redirect_to(view_url, allow_other_host: true)

      log_evidence_access(:view)
    end

    def download
      redirect_to(download_url, allow_other_host: true)

      log_evidence_access(:download)
    end

    private

    def download_url
      Datastore::Documents::Download.new(
        document: @document, log_context: log_context, inline: false
      ).call.url
    end

    def view_url
      Datastore::Documents::Download.new(
        document: @document, log_context: log_context, inline: true
      ).call.url
    end

    # Used for error reporting
    def log_context
      { caseworker_id: current_user_id, caseworker_ip: request.remote_ip, file_type: @document.content_type,
       s3_object_key: @document.s3_object_key }
    end

    def set_document
      @document = @crime_application.supporting_evidence.find { |evidence| evidence.s3_object_key == params[:id] }

      return @document if @document.present?

      set_flash(:cannot_download_doc_uploaded_to_another_app, success: false)
      redirect_to crime_application_path(params[:crime_application_id])
    end

    # Creates a searchable log entry for evaluating view/download behaviour
    def log_evidence_access(action)
      logger_method = action == :view ? :log_view : :log_download

      EvidenceAccessLogger.public_send(
        logger_method,
        crime_application: @crime_application,
        document: @document,
        current_user: current_user
      )
    end
  end
end

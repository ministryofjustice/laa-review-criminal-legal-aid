module Casework
  class DocumentsController < Casework::BaseController
    before_action :set_crime_application, :set_document
    before_action :require_doc_part_of_app

    class CannotDownloadUnlessAssigned < StandardError; end
    class CannotDownloadDocNotPartOfApp < StandardError; end

    def show
      @presign_download = Datastore::Documents::Download.new(document: @document, log_context: log_context).call
    end

    def download
      presign_download = Datastore::Documents::Download.new(document: @document, log_context: log_context).call

      if presign_download.respond_to?(:url)
        data = open(presign_download.url)
        send_data(data)
      else
        set_flash(:cannot_download_try_again, file_name: @document.filename, success: false)
        redirect_to crime_application_path(params[:crime_application_id])
      end
    end

    def downloady
      presign_download = Datastore::Documents::Download.new(document: @document, log_context: log_context).call

      if presign_download.respond_to?(:url)
        redirect_to(presign_download.url, allow_other_host: true)
      else
        set_flash(:cannot_download_try_again, file_name: @document.filename, success: false)
        redirect_to crime_application_path(params[:crime_application_id])
      end
    end

    private

    def log_context
      { caseworker_id: current_user_id, caseworker_ip: request.remote_ip, file_type: @document.content_type,
       s3_object_key: @document.s3_object_key }
    end

    def set_document
      @document = @crime_application.supporting_evidence.find { |evidence| evidence.s3_object_key == params[:id] }
    end

    def require_doc_part_of_app
      # To ensure users can only download documents that are part of the current application
      raise CannotDownloadDocNotPartOfApp if @document.blank?
    rescue CannotDownloadDocNotPartOfApp
      set_flash(:cannot_download_doc_uploaded_to_another_app, success: false)
      redirect_to crime_application_path(params[:crime_application_id])
    end
  end
end

module Casework
  class DocumentsController < Casework::BaseController
    before_action :set_crime_application, :set_document
    before_action :require_assigned_user

    class CannotDownloadUnlessAssigned < StandardError; end
    class CannotDownloadDocNotPartOfApp < StandardError; end

    def show; end

    def download
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

    def set_crime_application
      @crime_application = ::CrimeApplication.find(params[:crime_application_id])
    end

    def set_document
      @document = @crime_application.supporting_evidence.find { |evidence| evidence.s3_object_key == params[:id] }
    end

    def require_assigned_user
      # To ensure users can only download documents that are part of the current application
      raise CannotDownloadDocNotPartOfApp if @document.blank?
      raise CannotDownloadUnlessAssigned unless @crime_application.assigned_to?(current_user_id)
    rescue CannotDownloadUnlessAssigned
      set_flash(:cannot_download_unless_assigned, success: false)
      redirect_to crime_application_path(params[:crime_application_id])
    rescue CannotDownloadDocNotPartOfApp
      set_flash(:cannot_download_doc_uploaded_to_another_app, success: false)
      redirect_to crime_application_path(params[:crime_application_id])
    end
  end
end

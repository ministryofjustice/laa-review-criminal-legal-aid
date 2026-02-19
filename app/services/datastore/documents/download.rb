module Datastore
  module Documents
    class DownloadError < StandardError; end

    class Download
      PRESIGNED_URL_EXPIRES_IN = 15 # seconds

      attr_accessor :document, :log_context, :inline

      def initialize(document:, log_context:, inline: false)
        @document = document
        @log_context = log_context
        @inline = inline
      end

      def call
        Rails.error.handle(fallback: -> { raise DownloadError }, context: @log_context, severity: :error) do
          DatastoreApi::Requests::Documents::PresignDownload.new(
            object_key:, expires_in:, response_content_disposition:
          ).call
        end
      end

      private

      def object_key
        @document.s3_object_key
      end

      def expires_in
        PRESIGNED_URL_EXPIRES_IN
      end

      def response_content_disposition
        # To force download of file rather than opening in another window
        filename_safe = @document.filename.gsub(/[^a-zA-Z0-9._-]/, '_')
        filename_escaped = ERB::Util.url_encode(@document.filename)
        content_disposition = @inline ? 'inline' : 'attachment'
        %(#{content_disposition}; filename=#{filename_safe}; filename*= UTF-8''#{filename_escaped};)
      end
    end
  end
end

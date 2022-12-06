module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from Exception do |exception|
      case exception
      when DatastoreApi::Errors::NotFoundError
        redirect_to application_not_found_path
      # NOTE: Add more custom errors as they are needed, for instance:
      # when Errors::InvalidSession, ActionController::InvalidAuthenticityToken
      #   redirect_to invalid_session_path
      else
        raise if Rails.application.config.consider_all_requests_local

        Sentry.capture_exception(exception)
        redirect_to unhandled_path
      end
    end
  end
end

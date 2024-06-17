module Casework
  class BaseController < ApplicationController
    layout 'casework'

    before_action :authenticate_user!
    before_action :require_service_user!
    before_action :set_security_headers

    helper_method :assignments_count, :set_crime_application

    rescue_from DatastoreApi::Errors::ApiError do |e|
      Rails.error.report(e, handled: true, severity: :error)

      render status: :internal_server_error, template: 'errors/datastore_error'
    end

    rescue_from DatastoreApi::Errors::NotFoundError do
      render status: :not_found, template: 'errors/application_not_found'
    end

    private

    #
    # Users that can manage others are only allowed to access the Service on staging.
    # This is configured by the allow_user_managers_service_access feature flag.
    #
    def require_service_user!
      return if current_user.service_user?
      return if allow_user_managers_service_access?

      raise ForbiddenError, 'Must be a service user'
    end

    def assignments_count
      @assignments_count ||= CurrentAssignment.where(
        user_id: current_user_id
      ).count
    end

    def set_crime_application
      app_id_param = params.key?(:crime_application_id) ? params[:crime_application_id] : params[:id]
      @crime_application = CrimeApplication.find(app_id_param)
    end

    def current_crime_application
      @crime_application
    end
    helper_method :current_crime_application
  end
end

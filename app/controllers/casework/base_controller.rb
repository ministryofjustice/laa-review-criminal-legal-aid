module Casework
  class BaseController < ApplicationController
    layout 'casework'

    before_action :authenticate_user!
    before_action :require_service_user!
    before_action :set_security_headers
    before_action :set_current_work_stream

    helper_method :assignments_count, :current_work_stream

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

    def set_current_work_stream
      session[:current_work_stream] =
        Utils::CurrentWorkStreamCalculator.new(work_stream_param: params[:work_stream],
                                               session_work_stream: session[:current_work_stream],
                                               user_competencies: current_user.competencies).current_work_stream
    end

    def current_work_stream
      # TODO: enable when viewing applications by work stream feature is live
      if FeatureFlags.work_stream.enabled?
        [session[:current_work_stream]]
      else
        Types::WORK_STREAM_TYPES
      end
    end
  end
end

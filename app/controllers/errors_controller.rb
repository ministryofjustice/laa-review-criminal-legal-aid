class ErrorsController < ApplicationController
  before_action :set_response_format

  # The show action is configured as the Rails "exceptions_app" in /config/application.rb
  # config.exceptions_app = ->(env) {
  #   ErrorsController.action(:show).call(env)
  # }
  #
  def show
    render error_page, status:
  end

  # Used by Warden/Devise as the recall action
  def forbidden
    render status: :forbidden
  end

  private

  # Respond to all request formats with HTML
  # Otherwise errors from request for missing assets (.css, .js etc) will fail
  def set_response_format
    request.format = :html
  end

  # Determine the error page to render based on the status
  def error_page
    return :internal_server_error if status >= 500
    return :forbidden if status == 403
    return :unprocessable_entity if [422, 400].include? status

    :not_found
  end

  # Return status from path or set status to 404 if path is not an error status
  def status
    status_from_path = request.path_info[1..].to_i

    return 404 unless (400..511).cover?(status_from_path)

    status_from_path
  end
end

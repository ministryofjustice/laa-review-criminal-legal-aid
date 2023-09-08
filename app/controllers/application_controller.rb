class ApplicationController < ActionController::Base
  helper_method :current_user_id, :allow_user_managers_service_access?

  class ForbiddenError < StandardError; end

  rescue_from ForbiddenError do |_e|
    render status: :forbidden, template: 'errors/forbidden'
  end

  def landing_page_for(user)
    if user.service_user?
      assigned_applications_path
    elsif user.user_manager?
      admin_manage_users_root_path
    elsif user.reporting_user?
      reports_path
    end
  end

  private

  def current_user_id
    current_user&.id
  end

  def allow_user_managers_service_access?
    current_user.can_manage_others? && FeatureFlags.allow_user_managers_service_access.enabled?
  end

  def after_sign_in_path_for(user)
    url = landing_page_for(user)

    url.presence || super
  end

  # Sets the full flash message based on the message key.
  #
  # Like the AppTextHelper#named_text, it will scope locales according
  # to the text_namespace set on the controller. If none is set, it will
  # use root.
  #
  # Defaults to "success: true", pass option "success: false" to override.
  #
  # Any other options will be passed to I18n.translate.
  #
  def set_flash(message_key, options = {})
    success = options.fetch(:success, true)
    flash_key = success ? :success : :important

    message = I18n.t(
      message_key, scope: [try(:text_namespace), :flash, flash_key].compact,
      **options
    )

    # rubocop:disable Rails/ActionControllerFlashBeforeRender
    flash[flash_key] = message
    # rubocop:enable Rails/ActionControllerFlashBeforeRender
  end

  def set_security_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
  end
end

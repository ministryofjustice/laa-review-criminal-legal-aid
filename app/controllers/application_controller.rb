class ApplicationController < ActionController::Base
  include ErrorHandling

  before_action :authenticate_user!
  helper_method :current_user_id
  helper_method :assignments_count

  private

  def current_user_id
    current_user&.id
  end

  def assignments_count
    @assignments_count ||= CurrentAssignment.where(
      user_id: current_user_id
    ).count
  end

  def set_search(filter: ApplicationSearchFilter.new, sorting: {})
    sorting = Sorting.new(
      permitted_params[:sorting] || sorting.to_h
    )

    pagination = Pagination.new(
      current_page: permitted_params[:page],
      limit_value: permitted_params[:per_page]
    )

    @search = ApplicationSearch.new(
      filter:, sorting:, pagination:
    )
  end

<<<<<<< HEAD
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
=======
  def set_flash(message_key, options = {})
    success = options.delete(:success) || true
    flash_key = success ? :success : :important

    message = I18n.t(
      message_key, scope: [text_namespace, :flash, flash_key].compact,
>>>>>>> 094a05b (CRIMRE-320-manage-invitations)
      **options
    )

    # rubocop:disable Rails/ActionControllerFlashBeforeRender
    flash[flash_key] = message
    # rubocop:enable Rails/ActionControllerFlashBeforeRender
  end
end

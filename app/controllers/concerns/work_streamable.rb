module WorkStreamable
  extend ActiveSupport::Concern

  included do
    helper_method :current_work_stream
  end

  private

  attr_reader :current_work_stream

  def set_current_work_stream
    work_stream = WorkStream.from_param(work_stream_param)

    raise Allocating::WorkStreamNotFound unless current_user.work_streams.include?(work_stream)

    session[:current_work_stream] = work_stream_param

    @current_work_stream = work_stream
  end

  def work_stream_param
    params[:work_stream] || session[:current_work_stream] || current_user.work_streams.first.to_param
  end

  def require_app_work_stream
    return if current_user.work_streams.include?(
      @crime_application.work_stream
    )

    set_flash(
      :not_allocated_to_appropriate_work_stream,
      success: false,
      work_queue: @crime_application.work_stream.label
    )

    redirect_to crime_application_path @crime_application
  end
end

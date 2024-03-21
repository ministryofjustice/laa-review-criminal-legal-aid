module WorkStreamable
  extend ActiveSupport::Concern

  included do
    helper_method :current_work_stream
    helper_method :work_stream_filter
  end

  private

  attr_reader :current_work_stream

  def set_current_work_stream
    work_stream = if work_stream_param
                    WorkStream.from_param(work_stream_param)
                  else
                    current_user.work_streams.first
                  end

    raise Allocating::WorkStreamNotFound unless current_user.work_streams.include?(work_stream)

    session[:current_work_stream] = work_stream_param

    @current_work_stream = work_stream
  end

  def work_stream_param
    params[:work_stream] || work_stream_session_param
  end

  def work_stream_session_param
    return nil unless current_user.work_streams.map(&:to_param).include?(session[:current_work_stream])

    session[:current_work_stream]
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

  def work_stream_filter
    [current_work_stream]
  end
end

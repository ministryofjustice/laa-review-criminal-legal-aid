module WorkStreamable
  extend ActiveSupport::Concern

  included do
    helper_method :current_work_stream
  end

  private

  def set_current_work_stream
    work_stream = WorkStream.from_param(work_stream_param)

    raise Allocating::WorkStreamNotFound unless current_user.work_streams.include?(work_stream)

    session[:current_work_stream] = work_stream_param

    @current_work_stream = work_stream
  end

  def current_work_stream
    # TODO: enable when viewing applications by work stream feature is live
    raise 'Errorrrrr' unless FeatureFlags.work_stream.enabled?

    @current_work_stream
  end

  def work_stream_param
    params[:work_stream] || session[:current_work_stream] || current_user.work_streams.first.to_param
  end
end

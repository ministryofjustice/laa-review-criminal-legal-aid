module Utils
  class CurrentWorkStreamCalculator
    attr_reader :work_stream_param, :session_work_stream, :user

    def initialize(work_stream_param:, session_work_stream:, user:)
      @work_stream_param = work_stream_param
      @session_work_stream = session_work_stream
      @user = user
    end

    def current_work_stream
      if work_stream_param.present?
        WorkStream.from_param(work_stream_param)
      elsif session_work_stream.present?
        session_work_stream
      elsif user.present?
        user.work_streams.first
      else
        WorkStream.new(Types::WorkStreamType.values.first)
      end
    rescue Dry::Types::ConstraintError
      raise Allocating::WorkStreamNotFound
    end
  end
end

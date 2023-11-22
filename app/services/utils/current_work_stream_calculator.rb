module Utils
  class CurrentWorkStreamCalculator
    attr_reader :work_stream_param, :session_work_stream, :user_competencies

    def initialize(work_stream_param:, session_work_stream:, user_competencies:)
      @work_stream_param = work_stream_param
      @session_work_stream = session_work_stream
      @user_competencies = user_competencies
    end

    def current_work_stream
      if @work_stream_param.present?
        @work_stream_param
      elsif @session_work_stream.present?
        @session_work_stream
      elsif @user_competencies
        @user_competencies.first
      else
        Types::WorkStreamType.values.first
      end
    end
  end
end

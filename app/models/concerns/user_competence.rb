module UserCompetence
  extend ActiveSupport::Concern

  def work_streams
    @work_streams ||= (competencies & Types::WorkStreamType.values).map do |work_stream|
      WorkStream.new(work_stream)
    end
  end

  # Types of applications a user can process
  def application_types_competencies
    return [] if data_analyst?

    @application_types_competencies ||= competencies & Types::ApplicationType.values
  end

  def competencies
    return [] if data_analyst?

    @competencies ||= Allocating.user_competencies(id)
  end

  def competency_history
    @competency_history ||= AllocationHistory.new(user_id: id)
  end
end

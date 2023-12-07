module UserCompetence
  extend ActiveSupport::Concern

  def work_streams
    @work_streams ||= (competencies & Types::WorkStreamType.values).map do |work_stream|
      WorkStream.new(work_stream)
    end
  end

  def competencies
    return Types::CompetencyType.values if supervisor?
    return Types::CompetencyType.values unless FeatureFlags.work_stream.enabled?

    @competencies ||= Allocating.user_competencies(id)
  end

  def competency_history
    @competency_history ||= AllocationHistory.new(user_id: id)
  end
end

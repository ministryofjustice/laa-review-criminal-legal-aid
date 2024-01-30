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

    competencies_incl_initial = competencies.dup << Types::ApplicationType['initial']
    @application_types_competencies ||= (competencies_incl_initial &
      Types::ApplicationType.values).map do |application_type|
      application_type
    end
  end

  def competencies
    return Types::CompetencyType.values.dup if supervisor?
    return [] if data_analyst?

    @competencies ||= Allocating.user_competencies(id)
  end

  def competency_history
    @competency_history ||= AllocationHistory.new(user_id: id)
  end
end

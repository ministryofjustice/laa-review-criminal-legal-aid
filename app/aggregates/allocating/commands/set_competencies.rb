module Allocating
  class SetCompetencies < Command
    attribute :competencies, Types::Array.of(Types::CompetencyType)

    def call
      publish_event!
    end

    private

    def event
      CompetenciesSet.new(data: { user_id:, by_whom_id:, competencies: })
    end
  end
end

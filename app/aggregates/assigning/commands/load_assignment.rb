module Assigning
  class LoadAssignment < Command
    def call
      repository.load(
        Assignment.new(assignment_id), stream_name
      )
    end
  end
end

module Assigning
  class CannotAssignWhenAssigned < StandardError; end
  class CannotReassignUnlessAssigned < StandardError; end
  class StateHasChanged < StandardError; end

  class << self
    def stream_name(assignment_id)
      "Assigning$#{assignment_id}"
    end
  end
end

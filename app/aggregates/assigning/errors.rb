module Assigning
  class StateHasChanged < StandardError
  end

  class CannotReassignUnlessAssigned < StandardError
  end

  class CannotAssignWhenAssigned < StandardError
  end
end

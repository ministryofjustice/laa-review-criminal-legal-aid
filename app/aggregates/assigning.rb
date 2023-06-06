module Assigning
  class CannotAssignWhenAssigned < StandardError; end
  class CannotReassignUnlessAssigned < StandardError; end
  class StateHasChanged < StandardError; end
end

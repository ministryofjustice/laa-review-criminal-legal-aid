module Deciding
  class LoadDecision < Command
    def call
      repository.load(Decision.new(decision_id), stream_name)
    end
  end
end

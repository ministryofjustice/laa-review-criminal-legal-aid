module SubmissionHistory
  class Configuration
    def call(event_store)
      event_store.subscribe(
        SubmissionHistory::LinkToSubmissionHistoryStream, to: SubmissionHistory::EVENT_TYPES
      )
    end
  end
end

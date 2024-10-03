module Deciding
  class LinkDraft < Command
    attribute :application_id, Types::Uuid
    attribute :linked_decision, Maat::Decision

    def call
      with_decision do |decision|
        decision.link_draft(application_id: application_id, linked_decision: linked_decision.to_h)
      end
    end
  end
end

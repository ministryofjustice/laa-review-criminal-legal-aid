# Sync draft application decision with MAAT.
module Maat
  class UpdateLinkedDecision
    def initialize(application:)
      @application = application
    end

    # and check for decision action to decisions controller?
    # add sync with maat decision button to a decision?
    def call
      return unless application.status?(Types::ReviewState[:marked_as_ready])

      if linked?
        Deciding::UpdateFromLinkedDecision.call(decision_id:)
      elsif linked_maat_decision
        ActiveRecord::Base.transaction do
          Deciding::CreateMaatDraft.call(application_id:, maat_decision:, decision_id:)
          Reviewing::AddMaatDecision.call(application_id:, decision_id:)
        end
      end
    end

    private
    
    attr_reader :reference

    delegate :reference, to :application

    def linked_maat_decision
      reference = 10_002_679
      @linked_maat_decision ||= Maat::GetDecision.new.by_usn(reference)
    end

    def find_and_link
      return unless maat_decision

      decision_id = maat_decision.decision_id
      maat_id = maat_decision.maat_id
    end
  end
end

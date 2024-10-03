# Sync draft application decision with MAAT.
module Maat
  class SyncDecisions
    def initialize(application_id:, reference:, decision_ids:)
      @application_id = application_id
      @reference = reference
      @decision_ids = decision_ids
    end

    def call
      find_and_link if decision_ids.empty?

      decision_ids.each do |decision_id|
        Deciding::UpdateFromLinkedDecision.call(decision_id:)
      end
    end

    class << self
      def call(application)
        return unless application.status?(Types::ReviewState[:marked_as_ready])

        new(
          decision_ids: application.review.decision_ids,
          reference: 10_002_679, # application.reference,
          application_id: application.id
        ).call
      end
    end

    private

    attr_reader :application_id, :decision_ids, :reference

    def find_and_link
      linked_decision = Maat::GetDecision.new.by_usn(reference)

      return unless linked_decision

      decision_id = SecureRandom.uuid
      maat_id = linked_decision.maat_id

      ActiveRecord::Base.transaction do
        Deciding::LinkDraft.call(application_id:, linked_decision:, decision_id:)
        Reviewing::AddMaatDecision.call(application_id:, decision_id:, maat_id:)
      end
    end
  end
end

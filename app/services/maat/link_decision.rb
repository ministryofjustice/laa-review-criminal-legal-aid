module Maat
  class LinkDecision
    def initialize(application:, user_id:, maat_id: nil)
      @application = application
      @user_id = user_id
      @maat_id = maat_id
    end

    def call
      return nil unless maat_decision
      raise Deciding::ReferenceMismatch if reference_mismatch?

      create_or_update_draft_decision_from_maat

      link_draft_decision_to_application

      maat_decision
    end

    class << self
      def call(args)
        new(**args).call
      end
    end

    private

    attr_reader :application, :user_id, :maat_id

    delegate :application_type, to: :application
    delegate :decision_id, to: :maat_decision

    def reference_mismatch?
      return false if application.cifc?
      return false if maat_decision.reference.blank?

      maat_decision.reference != application.reference
    end

    def application_id
      application.id
    end

    def create_or_update_draft_decision_from_maat
      Deciding::CreateDraftFromMaat.call(
        decision_id:, maat_decision:, user_id:
      )
    end

    def link_draft_decision_to_application
      ActiveRecord::Base.transaction do
        Reviewing::AddDecision.call(application_id:, decision_id:, user_id:)

        Deciding::Link.call(
          application_id:, application_type:, decision_id:, user_id:
        )
      end
    end

    def maat_decision
      @decision ||= if maat_id
                      Maat::GetDecision.new.by_maat_id!(maat_id)
                    else
                      Maat::GetDecision.new.by_usn!(application.reference)
                    end

      return unless @decision

      Maat::DecisionTranslator.translate(@decision)
    end
  end
end

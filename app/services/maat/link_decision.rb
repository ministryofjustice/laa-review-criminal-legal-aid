module Maat
  class LinkDecision
    def initialize(application:, user_id:, maat_id: nil)
      @application = application
      @user_id = user_id
      @maat_id = maat_id
    end

    def call
      return nil unless maat_decision

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

    delegate :decision_id, to: :maat_decision

    def application_id
      application.id
    end

    def reference
      application.reference
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
          application_id:, application_type:, decision_id:, user_id:, reference:
        )
      end
    end

    def maat_decision
      @decision ||= if maat_id
                      Maat::GetDecision.new.by_maat_id!(maat_id)
                    else
                      Maat::GetDecision.new.by_usn!(reference)
                    end

      return unless @decision

      Maat::DecisionTranslator.translate(@decision)
    end

    # [CRIMAPP-1647] An application may only be determined as NAFI
    # during the process of being added to MAAT. Currently, NAFI
    # only affects the linking logic. Due to downstream technical limitations,
    # NAFI applications are linked to the earlier ineligible decision,
    # regardless of the firm submitting the new application.
    def application_type
      return 'new_application_following_ineligibility' if nafi?

      application.application_type
    end

    def new_application_following_ineligibility?
      @decision&.nafi? && application.initial?
    end
    alias nafi? new_application_following_ineligibility?
  end
end

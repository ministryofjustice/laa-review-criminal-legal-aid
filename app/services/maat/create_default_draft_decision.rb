module Maat
  class CreateDefaultDraftDecision
    def initialize(application:, user_id:)
      @application = application
      @user_id = user_id
    end

    def call
      ActiveRecord::Base.transaction do
        Reviewing::AddDecision.call(
          application_id:, user_id:, decision_id:
        )

        Deciding::CreateDraftFromMaat.call(
          application_id:, user_id:, decision_id:, maat_decision:
        )
      end

      maat_decision
    end

    class << self
      def call(args)
        new(**args).call
      end
    end

    private

    attr_reader :application, :user_id

    def application_id
      application.id
    end

    delegate :decision_id, to: :maat_decision

    def reference
      return application.reference unless application.cifc?

      application.pre_cifc_usn if application.usn_selected?
    end

    def maat_id
      return unless application.cifc?

      application.pre_cifc_maat_id
    end

    def maat_decision
      if reference.present?
        @maat_decision ||= Maat::GetDecision.new.by_usn!(reference)
      else
        @maat_decision ||= Maat::GetDecision.new.by_maat_id!(maat_id)
      end
    end
  end
end

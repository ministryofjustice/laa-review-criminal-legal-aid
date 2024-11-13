module Maat
  class CreateDraftDecisionFromReference
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
          application_id:, user_id:, decision_id:, maat_decision:, application_type:
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

    delegate :reference, :application_type, to: :application
    delegate :decision_id, to: :maat_decision

    def maat_decision
      @maat_decision ||= Maat::GetDecision.new.by_usn!(reference)
    end
  end
end

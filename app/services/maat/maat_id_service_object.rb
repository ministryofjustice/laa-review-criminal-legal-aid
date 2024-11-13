module Maat
  module MaatIdServiceObject
    extend ActiveSupport::Concern

    def initialize(application:, maat_id:, user_id:)
      @application = application
      @maat_id = maat_id
      @user_id = user_id
    end

    class_methods do
      def call(args)
        new(**args).call
      end
    end

    private

    attr_reader :application, :maat_id, :user_id

    delegate :reference, :cifc?, :application_type, to: :application
    delegate :decision_id, to: :maat_decision

    def application_id
      application.id
    end

    def maat_decision
      @maat_decision ||= Maat::GetDecision.new.by_maat_id!(maat_id)
    end
  end
end

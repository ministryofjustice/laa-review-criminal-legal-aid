module Deciding
  class Link < Command
    attribute :application_id, Types::Uuid
    attribute :application_type, Types::ApplicationType
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        if application_type == Types::ApplicationType['change_in_financial_circumstances']
          decision.link_to_cifc(application_id:, user_id:)
        else
          decision.link(application_id:, user_id:)
        end
      end
    end
  end
end

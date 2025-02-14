module Deciding
  class Link < Command
    attribute :application_id, Types::Uuid
    attribute :application_type, Types::ApplicationType
    attribute :reference, Types::ApplicationReference
    attribute :user_id, Types::Uuid

    def call
      with_decision do |decision|
        case application_type
        when 'change_in_financial_circumstances'
          decision.link_to_cifc(application_id:, user_id:)
        when 'new_application_following_ineligibility'
          decision.link_to_nafi(application_id:, user_id:)
        else
          decision.link(application_id:, user_id:, reference:)
        end
      end
    end
  end
end

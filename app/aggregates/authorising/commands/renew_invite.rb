module Authorising
  class RenewInvite < Command
    attribute :user_manager_id, Types::Uuid

    def call
      user.transaction do
        user.renew_invitation!
        event_store.publish(event, stream_name:)
      end
    end

    private

    def event
      InviteRenewed.new(data: { user_id:, user_manager_id: })
    end
  end
end

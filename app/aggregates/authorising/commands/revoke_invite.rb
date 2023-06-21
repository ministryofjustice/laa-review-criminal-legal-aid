module Authorising
  class RevokeInvite < Command
    attribute :user_manager_id, Types::Uuid

    def call
      user.transaction do
        user.destroy
        publish_event!
      end
    end

    private

    def event
      InviteRevoked.new(data: { user_id:, user_manager_id: })
    end
  end
end

module Authorising
  class Invite < Command
    attribute :user_manager_id, Types::Uuid

    def call
      user.transaction do
        user.save!
        publish_event!
      end
    end

    private

    def event
      Invited.new(data: { user_id:, user_manager_id: })
    end
  end
end

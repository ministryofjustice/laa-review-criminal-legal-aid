module Authorising
  class Deactivate < Command
    attribute :user_manager_id, Types::Uuid

    def call
      user.transaction do
        user.deactivate!
        event_store.publish(event, stream_name:)
      end
    end

    private

    def event
      Deactivated.new(data: { user_id:, user_manager_id: })
    end
  end
end

module Authorising
  class Activate < Command
    attribute :auth_subject_id, Types::Uuid

    def call
      user.transaction do
        user.save!
        event_store.publish(event, stream_name:)
      end
    end

    private

    def event
      Activated.new(data: { user_id:, auth_subject_id: })
    end
  end
end

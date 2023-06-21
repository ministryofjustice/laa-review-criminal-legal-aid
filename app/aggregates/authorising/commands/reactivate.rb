module Authorising
  class Reactivate < Command
    attribute :user_manager_id, Types::Uuid

    def call
      user.transaction do
        user.reactivate!
        publish_event!
      end
    end

    private

    def event
      Reactivated.new(data: { user_id:, user_manager_id: })
    end
  end
end

module Authorising
  class Reactivate < Command
    attribute :user_manager_id, Types::Uuid

    def call
      raise User::CannotReactivate if user.id == user_manager_id

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

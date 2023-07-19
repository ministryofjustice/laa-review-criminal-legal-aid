module Authorising
  class Revive < Command
    attribute :user_manager_id, Types::Uuid

    def call
      return if user.revive_until.blank?

      user.transaction do
        user.update!(revive_until: nil)

        publish_event!
      end
    end

    private

    def event
      Revived.new(data: { user_id:, user_manager_id: })
    end
  end
end

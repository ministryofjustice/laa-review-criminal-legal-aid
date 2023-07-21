module Authorising
  class Revive < Command
    def call
      return unless user.revive_until.present? && user.revive_until >= Time.zone.now

      user.transaction do
        user.update!(revive_until: nil)

        publish_event!
      end
    end

    private

    def event
      Revived.new(data: { user_id: })
    end
  end
end

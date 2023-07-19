module Authorising
  class Revive < Command
    def call
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

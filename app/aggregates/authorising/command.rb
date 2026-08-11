module Authorising
  class Command < Dry::Struct
    attribute :user, Types.Instance(User)

    # simplecov:disable
    def call
      raise 'implement in subclasses'
    end
    # simplecov:enable

    private

    def publish_event!
      Rails.configuration.event_store.publish(
        event,
        stream_name: Authorising.stream_name(user_id)
      )
    end

    # simplecov:disable
    def event
      raise 'define event in subclasses'
    end
    # simplecov:enable

    def user_id
      user.id
    end

    class << self
      def call(args)
        new(args).call
      end
    end
  end
end

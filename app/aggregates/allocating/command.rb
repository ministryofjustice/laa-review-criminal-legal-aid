module Allocating
  class Command < Dry::Struct
    attribute :user, Types.Instance(User)
    attribute :by_whom, Types.Instance(User)

    # :nocov:
    def call
      raise 'implement in subclasses'
    end
    # :nocov:

    private

    def publish_event!
      Rails.configuration.event_store.publish(
        event,
        stream_name: Allocating.stream_name(user_id)
      )
    end

    # :nocov:
    def event
      raise 'define event in subclasses'
    end
    # :nocov:

    def user_id
      user.id
    end

    def by_whom_id
      by_whom.id
    end

    class << self
      def call(args)
        new(args).call
      end
    end
  end
end

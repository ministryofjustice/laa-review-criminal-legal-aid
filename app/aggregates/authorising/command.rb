module Authorising
  class Command < Dry::Struct
    attribute :user, Types.Instance(User)

    # :nocov:
    def call
      raise 'implement in subclasses'
    end
    # :nocov:

    private

    def event_store
      Rails.configuration.event_store
    end

    def stream_name
      "Authorisation$#{user_id}"
    end

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

module Authorising
  class AwaitRevival < Command
    attribute :user_manager_id, Types::Uuid

    def call
      raise User::CannotAwaitRevival, 'User must be dormant' unless user.dormant?
      raise User::CannotAwaitRevival, 'Cannot revive yourself' if user.id == user_manager_id

      perform
    end

    private

    def perform
      user.transaction do
        user.revive_until = Rails.configuration.x.auth.dormant_account_revive_ttl.from_now
        user.save!
        NotifyMailer.revive_account_email(user.email).deliver_now

        publish_event!
      end
    end

    def event
      RevivalAwaited.new(data: { user_id:, user_manager_id: })
    end
  end
end

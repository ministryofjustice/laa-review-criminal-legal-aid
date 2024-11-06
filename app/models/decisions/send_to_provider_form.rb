# form object for choosing the next step once one or more decisions have been added
module Decisions
  class SendToProviderForm
    include FormPersistance

    attribute :application_id, :immutable_string
    attribute :next_step, :string

    attr_readonly :application_id

    validates :next_step, inclusion: %w[add_another send_to_provider]

    alias send_to_provider! create_with_user!

    private

    def persist(user_id)
      return unless next_step == 'send_to_provider'

      Reviewing::Complete.call(application_id:, user_id:)
    rescue Reviewing::IncompleteDecisions => e
      errors.add(:base, :incomplete_decisions)
      raise e
    end
  end
end

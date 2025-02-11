module Decisions
  class MaatIdForm
    include DecisionFormPersistance

    FIRST_MAAT_ID = Rails.configuration.x.maat_api.first_supported_maat_id.to_i
    attribute :maat_id, :integer

    validates :maat_id, presence: true
    validates :maat_id, numericality: { greater_than: FIRST_MAAT_ID }

    def create_with_user!(params, user_id)
      self.maat_id = params[:maat_id]
      validate!

      persist(user_id)
    end

    private

    alias decision_id maat_id

    def persist(user_id)
      Maat::LinkDecision.call(application:, maat_id:, user_id:)
    rescue Maat::RecordNotFound, Deciding::Error, Reviewing::Error => e
      errors.add(:maat_id, e.class.name.demodulize.underscore.to_sym)

      raise e
    end
  end
end

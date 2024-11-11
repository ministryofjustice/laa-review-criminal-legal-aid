module Decisions
  class MaatIdForm
    include DecisionFormPersistance

    FIRST_MAAT_ID = Rails.configuration.x.maat_api.first_supported_maat_id.to_i
    attribute :maat_id, :integer

    validates :maat_id, presence: true
    validates :maat_id, numericality: { greater_than: FIRST_MAAT_ID }

    validate :maat_decision_found_for_id

    def maat_decision
      return nil if maat_id.to_i.blank?

      @maat_decision ||= Maat::GetDecision.new.by_maat_id(maat_id)
    end

    def create_with_user!(params, user_id)
      self.maat_id = params[:maat_id]
      validate!

      persist(user_id)
    end

    private

    alias decision_id maat_id

    def maat_decision_found_for_id
      return errors.add(:maat_id, :not_found) if maat_decision.blank?
    end

    def persist(user_id)
      ActiveRecord::Base.transaction do
        Deciding::CreateDraftFromMaat.call(application_id:, user_id:, decision_id:, maat_decision:, application_type:)
        Reviewing::AddDecision.call(application_id:, user_id:, decision_id:)
      end
    rescue Deciding::Error => e
      errors.add(:maat_id, e.message_key)

      raise e
    end
  end
end

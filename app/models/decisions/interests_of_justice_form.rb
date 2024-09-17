module Decisions
  class InterestsOfJusticeForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Dirty

    attribute :application_id, :immutable_string
    attribute :decision_id, :immutable_string

    attribute :result, :string
    attribute :details, :string
    attribute :assessed_by, :string
    attribute :assessed_on, :date

    validates :result, inclusion: { in: :possible_results }
    validates :details, :assessed_by, presence: true
    validates :assessed_on, presence: true

    def possible_results
      Types::InterestsOfJusticeResult.values
    end

    def update_with_user!(attributes, user_id)
      assign_attributes(attributes)
      validate!
      return unless changed?

      Deciding::SetInterestsOfJustice.new(
        decision_id: decision_id,
        user_id: user_id,
        interests_of_justice: self.attributes.deep_symbolize_keys
      ).call
    end

    class << self
      def build(decision)
        new(
          **(decision.interests_of_justice || {}),
          application_id: decision.application_id,
          decision_id: decision.decision_id
        )
      end
    end
  end
end

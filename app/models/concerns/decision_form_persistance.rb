module DecisionFormPersistance
  extend ActiveSupport::Concern

  included do
    include FormPersistance

    attribute :application_id, :immutable_string
    attribute :reference, :integer
    attribute :decision_id, :immutable_string

    attr_readonly :application_id, :decision_id, :reference
  end
end

module DecisionFormPersistance
  extend ActiveSupport::Concern

  included do
    include FormPersistance

    attribute :application_id, :immutable_string
    attribute :application_type, :immutable_string
    attribute :reference, :integer
    attribute :decision_id, :immutable_string

    attr_readonly :application_id, :application_type, :decision_id, :reference
  end
end

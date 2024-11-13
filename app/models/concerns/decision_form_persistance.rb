module DecisionFormPersistance
  extend ActiveSupport::Concern

  included do
    include FormPersistance

    attribute :application
    attribute :decision_id, :immutable_string

    attr_readonly :application, :decision_id

    delegate :application_id, :application_type, to: :application
  end
end

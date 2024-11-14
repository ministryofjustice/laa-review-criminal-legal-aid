module DecisionFormPersistance
  extend ActiveSupport::Concern

  included do
    include FormPersistance

    attribute :application
    attribute :decision_id, :immutable_string

    attr_readonly :application, :decision_id, :application_id, :reference, :application_type

    delegate :reference, :application_type, to: :application

    delegate :id, to: :application, prefix: true
  end
end

module DecisionFormPersistance
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :application_id, :immutable_string
    attribute :decision_id, :immutable_string
  end

  def update_with_user!(new_attributes, user_id)
    old_values = editable_attribute_values
    assign_attributes(new_attributes)
    validate!

    persist(user_id) unless old_values == editable_attribute_values
  end

  class_methods do
    def permit_params(params = {})
      params[model_name.singular].permit(*editable_attributes)
    end

    def editable_attributes
      immutable_attributes = :application_id, :decision_id

      attribute_names.map(&:to_sym) - immutable_attributes
    end
  end

  private

  def editable_attribute_values
    values_at(*self.class.editable_attributes)
  end

  def persist(user_id)
    command_class.call(
      **attributes.symbolize_keys.merge(user_id:)
    )
  end

  # :nocov:
  def command_class
    raise 'Deciding command class must be defined'
  end
  # :nocov:
end

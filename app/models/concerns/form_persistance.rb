module FormPersistance
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::ReadonlyAttributes
    include ActiveRecord::AttributeAssignment
  end

  def update_with_user!(new_attributes, user_id)
    raise_if_read_only!(new_attributes)

    old_values = editable_attribute_values
    assign_attributes(new_attributes)
    validate!

    persist(user_id) unless old_values == editable_attribute_values
  end

  def create_with_user!(attrs, user_id)
    raise_if_read_only!(attrs)

    assign_attributes(attrs)
    validate!

    persist(user_id)
  end

  class_methods do
    def permit_params(params = {})
      params[model_name.singular]&.permit(*editable_attributes) || {}
    end

    def editable_attributes
      attribute_names - readonly_attributes
    end
  end

  private

  def raise_if_read_only!(attributes)
    attributes.each_key do |attr_name|
      next unless self.class.readonly_attribute?(attr_name.to_s)

      raise ActiveRecord::ReadonlyAttributeError, attr_name
    end
  end

  def editable_attribute_values
    values_at(*self.class.editable_attributes)
  end

  def persist(user_id)
    attrs = attributes.slice(*self.class.editable_attributes)

    base_attrs = {
      application_id:, reference:, application_type:, decision_id:, user_id:
    }

    command_class.call(**attrs.symbolize_keys, **base_attrs)
  end

  # :nocov:
  def command_class
    raise 'Deciding command class must be defined'
  end
  # :nocov:
end

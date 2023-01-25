class ApplicationStruct < Dry::Struct
  transform_keys(&:to_sym)

  include ActiveModel::Validations

  def to_partial_path
    self.class.name.split('::').last.underscore
  end
end

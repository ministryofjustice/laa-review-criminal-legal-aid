class ApplicationStruct < Dry::Struct
  # convert string keys to symbols
  transform_keys(&:to_sym)

  def to_partial_path
    self.class.name.split('::').last.underscore
  end
end

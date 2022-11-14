class ApplicationStruct < Dry::Struct
  # convert string keys to symbols
  transform_keys(&:to_sym)

  def to_partial_path
    self.class.name.split('::').last.underscore
  end

  def publish(_event_klass, args)
    event_store.publish(
      Assigning::AssignedToUser.new(**args),
      stream_name:
    )
  end

  def event_store
    Rails.configuration.event_store
  end

  def stream_name
    "#{self.class.name}$#{id}"
  end

  def event_stream
    event_store.read.stream(stream_name)
  end
end

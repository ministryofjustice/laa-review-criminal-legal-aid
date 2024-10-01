class DateStampContext
  def initialize(crime_application)
    @crime_application = crime_application
    @date_stamp_context = crime_application[:date_stamp_context]
  end

  def applicant
    @applicant ||=
      (@crime_application.client_details.applicant if @crime_application&.client_details)
  end

  def method_missing(name, *args)
    super unless @date_stamp_context.respond_to?(name)

    @date_stamp_context.send(name, *args)
  end

  def respond_to_missing?(name, _include_private = false)
    @date_stamp_context.respond_to?(name) || super
  end

  def to_partial_path
    self.class.name.split('::').last.underscore
  end
end

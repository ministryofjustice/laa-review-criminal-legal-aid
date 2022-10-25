class ApiClient
  def initialize(connection: nil)
    @connection = connection || default_connection
  end

  def all(_options = {})
    response = @connection.get('applications')

    return [] unless response.success?

    JSON.parse(response.body)
  end

  # Returns nil if a resource is not found OR there is
  # a problem with the api.
  #
  def find(id)
    response = @connection.get("applications/#{id}")

    return nil unless response.success?

    JSON.parse(response.body)
  end

  private

  def default_connection
    Faraday.new(
      url: ENV.fetch('CRIME_APPLY_API_URL'),
      ssl: { verify: !Rails.env.development? },
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end

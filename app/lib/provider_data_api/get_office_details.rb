module ProviderDataApi
  class GetOfficeDetails
    def initialize(office_code:, http_client: HttpClient.call)
      @office_code = office_code
      @http_client = http_client
    end

    def call
      response = http_client.get(offices_endpoint(office_code))
      OfficeDetails.new(response.body)
    rescue Faraday::ResourceNotFound
      raise RecordNotFound
    end

    class << self
      def call(office_code)
        return MockGetOfficeDetails.call(office_code) if mock?

        new(office_code:).call
      end

      private

      def mock?
        Rails.configuration.x.provider_data_api.use_mock == 'true'
      end
    end

    private

    attr_reader :office_code, :http_client

    def offices_endpoint(office_code)
      path = "/provider-offices/#{office_code}"

      URI::Generic.build(path:)
    end
  end
end

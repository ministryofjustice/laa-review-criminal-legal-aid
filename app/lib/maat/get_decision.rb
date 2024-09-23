module Maat
  class GetDecision
    USN_FORMAT =     '/api/external/v1/crime-application/result/usn/%d'.freeze
    MAAT_ID_FORMAT = '/api/external/v1/crime-application/result/rep-order-id/%s'.freeze

    def initialize(http_client: Maat::HttpClient.call)
      @http_client = http_client
    end

    def by_usn(usn)
      get(format(USN_FORMAT, usn))
    end

    def by_maat_id(maat_id)
      get(format(MAAT_ID_FORMAT, maat_id))
    end

    private

    # By default, Maat::HttpClient configures the Faraday client to
    # raise an error on bad requests or server errors (e.g., Faraday::BadRequestError).
    def get(path)
      return if http_client.blank?

      response = http_client.get(path)

      # NOTE: The MAAT API returns a 200 status even if a decision has not been found.
      # The existence of the decision can only be determined by checking if
      # the response body is empty.
      return nil if response.body.empty?

      Decision.build(response.body)
    end

    attr_reader :http_client
  end
end

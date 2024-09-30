module Maat
  class HttpClient
    def initialize(host: Rails.configuration.x.maat_api.api_url, raise_errors: true)
      @host = host
      @raise_errors = raise_errors
    end

    def call
      return if host.blank?

      Faraday.new host do |connection|
        connection.request :authorization, 'Bearer', access_token.token
        connection.request :json
        connection.response :json
        connection.response(:raise_error) if raise_errors

        connection.adapter Faraday.default_adapter
      end
    end

    class << self
      delegate :call, to: :new
    end

    private

    attr_reader :host, :raise_errors

    def access_token
      return @access_token if @access_token && !@access_token.expired?

      @access_token = auth_client.client_credentials.get_token
    end

    def auth_client
      @auth_client ||= OAuth2::Client.new(
        Rails.configuration.x.maat_api.client_id,
        Rails.configuration.x.maat_api.client_secret,
        site: Rails.configuration.x.maat_api.oauth_url,
        token_url: '/oauth2/token',
        auth_scheme: :basic_auth,
        scope: 'caa-api-uat/standard'
      )
    end
  end
end

module Aws
  class SnsMessage
    attr_reader :id, :body, :message

    def initialize(id:, raw_body:)
      @id = id
      @body = json(from: raw_body)
      @message = json(from: body['Message'])
    end

    def event_name
      message['event_name']
    end

    def data
      message['data']
    end

    private

    def json(from:)
      Rails.error.handle(fallback: -> { {} }) do
        JSON.parse(from)
      end
    end
  end
end

module SnsEvent
  class ReceiveApplicationEvent
    attr_reader :headers, :request_body, :message, :last_http_status

    def initialize(sns_message:, headers: {})
      raise ArgumentError, 'Headers must be an Enumerable type' unless headers.respond_to?(:key?)

      @headers = headers
      @request_body = json(from: sns_message)
      @message = json(from: request_body['Message'])
    end

    def create!
      Reviewing::ReceiveApplication.call(
        application_id:,
        parent_id:,
        causation_id:,
        submitted_at:
      )
    end

    def confirm!
      raise ArgumentError, 'Cannot confirm SNS topic subscription without valid SubscribeURL' if subscribe_url.blank?

      response = Faraday.get(subscribe_url)
      response.status
    end

    def application_id
      message.dig('data', 'id')
    end

    def submitted_at
      message.dig('data', 'submitted_at') || Time.zone.now.to_s
    end

    def parent_id
      message['data']&.fetch('parent_id', application_id)
    end

    def causation_id
      message_id
    end

    def raw?
      headers['x-amz-sns-rawdelivery']&.strip&.downcase == 'true'
    end

    def message_id
      headers['x-amz-sns-message-id']
    end

    def topic_arn
      @topic_arn ||= request_body.fetch('TopicArn', '').strip
    end

    def subscribe_url
      @subscribe_url ||= request_body.fetch('SubscribeURL', '')
    end

    def message_type
      headers['x-amz-sns-message-type']&.strip
    end

    def confirmation?
      message_type == 'SubscriptionConfirmation'
    end

    def notification?
      message_type == 'Notification'
    end

    def valid?
      return false if request_body.blank?

      true
    end

    def invalid?
      !valid?
    end

    def json(from:)
      Rails.error.handle(fallback: -> { {} }) do
        JSON.parse(from)
      end
    end

    def to_json(*args)
      JSON.generate(request_body, *args)
    end
  end
end

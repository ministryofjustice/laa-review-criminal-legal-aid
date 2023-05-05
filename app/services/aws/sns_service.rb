module AWS
  class SNSService
    ALLOWED_AWS_ACCOUNTS = [
      'arn:aws:sns:eu-west-2:754256621582:',
    ].freeze

    attr_reader :headers, :request_body, :message, :last_http_status

    def initialize(raw_message:, headers:)
      @headers = headers
      @request_body = JSON.parse(raw_message) rescue {}
      @message = JSON.parse(request_body.fetch('Message')) rescue {}
    end

    def call(&on_notification)
      @result =
        if confirmation?
          confirm!
        elsif notification?
          on_notification&.call
        else
          :unknown
        end
    end

    def valid?
      return false if request_body.blank?
      return false unless topic_allowed?

      message_verifier.authenticate!(request_body.to_json)
    end

    def invalid?
      !valid?
    end

    def topic_allowed?
      return false if topic_arn.blank?

      ALLOWED_AWS_ACCOUNTS.any? { |arn| topic_arn.starts_with?(arn) }
    end

    def topic_arn
      @topic_arn ||= request_body.fetch('TopicArn', '').strip
    end

    def raw_request_delivery?
      headers['x-amz-sns-rawdelivery'] == 'true'
    end

    def message_id
      headers['x-amz-sns-message-id']
    end

    def message_verifier
      @message_verifier ||= Aws::SNS::MessageVerifier.new
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

    def confirm!
      confirm_url = request_body.fetch('SubscribeURL', '')

      raise ArgumentError, 'Cannot confirm SNS topic subscription without valid SubscribeURL' if confirm_url.blank?

      response = Faraday.get(confirm_url)
      response.status
    end
  end
end

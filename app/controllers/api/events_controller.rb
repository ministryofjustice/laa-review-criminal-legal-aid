module Api
  class EventsController < ActionController::API
    #
    # TODO extract to middleware if we go down this route....
    # TODO: verify message
    #
    def create
      #
      # Return 204 for a succesfull notification
      # Return 200 for other types
      # Return confirm endpoint status for subscription confirm.
      #

      case request.headers.fetch('x-amz-sns-message-type')
      when 'SubscriptionConfirmation'
        confirm_subscription!
      when 'Notification'
        handle_notification!
      else
        head :ok
      end
    end

    private

    def confirm_subscription!
      response = Faraday.get(confirm_url)

      head response.status
    end

    def handle_notification!
      message_id = request.headers.fetch('x-amz-sns-message-id')

      correlation_id = message_id

      Reviewing::ReceiveApplication.call(application_id:, correlation_id:)

      head :created
    rescue Reviewing::AlreadyReceived
      head :ok
    end

    #
    # TODO: simplify when notification message format decided.
    #
    def application_id
      if request.headers['x-amz-sns-rawdelivery'] == 'true'
        data = request_body.fetch('data', request_body)
        data.fetch('id')
      else
        JSON.parse(request_body.fetch('Message')).fetch('id')
      end
    end

    def confirm_url
      request_body.fetch('SubscribeURL')
    end

    def request_body
      @request_body ||= JSON.parse(request.body.read)
    end
  end
end

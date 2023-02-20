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

      log_request_for_debugging

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
      confirm_url = params['SubscribeURL']
      response = Faraday.get(confirm_url)

      head response.status
    end

    def handle_notification!
      application_id = JSON.parse(params['Message'])['id']
      message_id = request.headers.fetch('x-amz-sns-message-id')
      correlation_id = message_id

      Reviewing::ReceiveApplication.call(application_id:, correlation_id:)

      head :created
    rescue Reviewing::AlreadyReceived
      head :ok
    end

    def log_request_for_debugging
      logger.info('>' * 100)
      logger.info(request.headers.env.to_hash)
      logger.info(params.inspect)
      logger.info('<' * 100)
    end
  end
end

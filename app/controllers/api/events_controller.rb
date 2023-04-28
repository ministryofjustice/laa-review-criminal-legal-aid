require 'aws-sdk-sns'

module Api
  class EventsController < ActionController::API
    before_action :verify_request_authenticity, unless: :raw_request_delivery?

    #
    # TODO extract to middleware if we go down this route....
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
      Reviewing::ReceiveApplication.call(
        application_id:,
        causation_id:,
        parent_id:,
        submitted_at:
      )

      head :created
    rescue Reviewing::AlreadyReceived
      head :ok
    end

    def application_id
      message.dig('data', 'id')
    end

    def submitted_at
      message.dig('data', 'submitted_at') || Time.zone.now.to_s
    end

    def parent_id
      message.fetch('data').fetch('parent_id', nil)
    end

    def causation_id
      request.headers.fetch('x-amz-sns-message-id')
    end

    def message
      if raw_request_delivery?
        request_body
      else
        JSON.parse(request_body.fetch('Message'))
      end
    end

    def confirm_url
      request_body.fetch('SubscribeURL')
    end

    def request_body
      @request_body ||= JSON.parse(request.body.read)
    end

    def verify_request_authenticity
      return head :unauthorized if request_body.blank?

      message_verifier.authenticate!(request_body.to_json)
    end

    def raw_request_delivery?
      request.headers['x-amz-sns-rawdelivery'] == 'true'
    end

    def message_verifier
      @message_verifier ||= Aws::SNS::MessageVerifier.new
    end
  end
end

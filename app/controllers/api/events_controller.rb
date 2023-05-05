require 'aws-sdk-sns'

module Api
  class EventsController < ActionController::API
    before_action :verify!

    # NOTE: Raw messages are currently unsupported
    def verify!
      if sns_service.raw_request_delivery?
        head status: 451
      elsif sns_service.invalid?
        head :unauthorized
      end

      true
    end

    def create
      sns_service.call(on_notfication: handle_notification)

      head status: sns_service.result.to_sym
    end

    private

    # NOTE: callback must return valid HTTP status code/name
    def handle_notification
      Reviewing::ReceiveApplication.call(
        application_id:,
        correlation_id:,
        causation_id:,
        submitted_at:
      )

      :created
    rescue Reviewing::AlreadyReceived
      :ok
    end

    def application_id
      message.dig('data', 'id')
    end

    def submitted_at
      message.dig('data', 'submitted_at') || Time.zone.now.to_s
    end

    def correlation_id
      message['data']&.fetch('parent_id', application_id)
    end

    def causation_id
      sns_service.message_id
    end

    def message
      sns_service.message
    end

    def sns_service
      @sns_service ||= AAWS::SNSService.new(raw_message: request.body.read)
    end
  end
end

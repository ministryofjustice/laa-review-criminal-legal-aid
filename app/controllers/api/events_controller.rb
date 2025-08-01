require 'aws-sdk-sns'

module Api
  class EventsController < ActionController::API
    before_action :verify!

    def create
      head sns_service.call
    rescue Reviewing::AlreadyReceived
      head :ok
    end

    private

    def sns_service
      @sns_service ||= Aws::SnsService.new(sns_event:)
    end

    def sns_event
      @sns_event ||= SnsEvent::ReceiveApplicationEvent.new(
        sns_message: request.body.read,
        headers: request.headers
      )
    end

    def verify!
      return head :unprocessable_entity if FeatureFlags.sqs_polling.enabled?

      if sns_event.raw?
        head :unavailable_for_legal_reasons
      elsif sns_event.invalid?
        head :unprocessable_entity
      elsif sns_service.disallowed?
        head :unauthorized
      end

      true
    end
  end
end

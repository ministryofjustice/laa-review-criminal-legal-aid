require 'aws-sdk-sns'

module Api
  class EventsController < ActionController::API
    before_action :verify!

    def create
      head status: handle_notification.to_sym
    end

    private

    def handle_notification
      sns_service.call

      :created
    rescue Reviewing::AlreadyReceived
      :ok
    end

    def sns_service(sns_event)
      @sns_service ||= Aws::SnsService.new(sns_event:)
    end

    def sns_event
      @sns_event ||= ReceiveApplicationSnsEvent.new(
        sns_message: request.body.read,
        headers: request.headers
      )
    end

    def verify!
      if sns_service.raw?
        head status: 451 # Unavailable for legal reasons!
      elsif sns_service.disallowed?
        head :unauthorized
      elsif sns_event.invalid?
        head :forbidden
      end

      true
    end
  end
end

module Api
  class EventsController < ActionController::API
    #
    # TODO extract to middleware if we go down this route....
    # TODO: verify message
    #
    def create
      #
      # Only care about Notifcations for now
      # return 200 for other types in case SNS needs it to move on on
      #
      type = request.headers.fetch('x-amz-sns-message-type')
      head :ok and return unless type == 'Notification'

      application_id = JSON.parse(params['Message'])['id']
      message_id = request.headers.fetch('x-amz-sns-message-id')
      correlation_id = message_id

      Reviewing::ReceiveApplication.call(application_id:, correlation_id:)

      head :created
    rescue Reviewing::AlreadyReceived
      # return okay so SNS can move on if already recieved.
      head :ok
    end
  end
end

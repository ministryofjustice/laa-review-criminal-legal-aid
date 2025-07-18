class AwsMessageProcessingJob < ApplicationJob
  queue_as :aws_messages

  def perform(message_id, message_body)
    message = Aws::SnsMessage.new(id: message_id, raw_body: message_body)
    Aws::MessageProcessor.process!(message)
  end
end

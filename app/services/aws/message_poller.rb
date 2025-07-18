require 'aws-sdk-sqs'

module Aws
  class MessagePoller
    def initialize(queue_url:)
      @queue_url = queue_url
      @sqs_client = Aws::SQS::Client.new
      @finish = false
    end

    def start! # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      Rails.logger.info('Message poller started...')
      trap_signals
      loop do
        break if @finish

        res = @sqs_client.receive_message(
          queue_url: @queue_url,
          message_system_attribute_names: ['SentTimestamp'],
          message_attribute_names: ['All'],
          max_number_of_messages: 10,
          wait_time_seconds: 20
        )

        res.messages.each do |message|
          Rails.logger.info("Message #{message.message_id} received")
          AwsMessageProcessingJob.perform_later(message.message_id, message.body)
          Rails.logger.info("Message #{message.message_id} scheduled for processing")
          @sqs_client.delete_message(queue_url: @queue_url, receipt_handle: message.receipt_handle)
          Rails.logger.info("Message #{message.message_id} removed from queue")
        end
      end

      Rails.logger.info('Message poller shutting down...')
    end

    private

    # Allow the main loop to finish before shutting down
    def trap_signals
      %w[INT TERM].each do |signal|
        Signal.trap(signal) { @finish = true }
      end
    end
  end
end

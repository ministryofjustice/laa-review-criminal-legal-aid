require 'aws-sdk-sqs'

READY_FILE = Rails.root.join('tmp/poller_ready').freeze

module Aws
  class MessagePoller
    def initialize(queue: nil)
      @sqs_client = Aws::SQS::Client.new
      @queue_url = get_queue_url(queue)
      @finish = false
      configure_logger!
    end

    def start! # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      Rails.logger.info('Message poller started...')
      trap_signals
      ready
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

    def get_queue_url(queue)
      return ENV.fetch('SQS_QUEUE_URL') if Rails.env.development?

      @sqs_client.get_queue_url(queue_name: queue).queue_url
    end

    def ready
      FileUtils.touch(READY_FILE)
    end

    # Allow the main loop to finish before shutting down
    def trap_signals
      %w[INT TERM].each do |signal|
        Signal.trap(signal) { @finish = true }
      end
    end

    # :nocov:
    def configure_logger!
      return if ENV['RAILS_LOG_TO_STDOUT'].blank?

      $stdout.sync = true
      logger = ActiveSupport::Logger.new($stdout)
      logger.formatter = Logger::Formatter.new
      logger.level = Logger::INFO

      Rails.logger = ActiveSupport::TaggedLogging.new(logger)
    end
    # :nocov:
  end
end

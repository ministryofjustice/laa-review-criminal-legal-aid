module Aws
  class SnsService
    ALLOWED_AWS_ACCOUNTS = [
      'arn:aws:sns:eu-west-2:754256621582:',
    ].freeze

    attr_reader :sns_event

    def initialize(sns_event:)
      @sns_event = sns_event
    end

    # @return [Symbol] rails HTTP status name
    # rubocop:disable Metrics/AbcSize
    def call
      if sns_event.confirmation? && confirmation_allowed?
        Rails.logger.info "[#{self.class.name}] Confirmation event. URL: #{sns_event.subscribe_url}"
        sns_event.confirm!
        Rails.logger.info "[#{self.class.name}] Subscription successfully confirmed."
        :ok
      elsif sns_event.notification?
        Rails.logger.info "[#{self.class.name}] Event received: #{sns_event.message}"
        sns_event.create!
        :created
      else
        :forbidden
      end
    end
    # rubocop:enable Metrics/AbcSize

    def allowed?
      return true if local_bypass?
      return false unless topic_allowed?

      message_verifier.authenticate!(sns_event.to_json)
    end

    def disallowed?
      !allowed?
    end

    def topic_allowed?
      return false if sns_event.topic_arn.blank?

      ALLOWED_AWS_ACCOUNTS.any? { |arn| sns_event.topic_arn.starts_with?(arn) }
    end

    def confirmation_allowed?
      return true if local_bypass?
      return false if sns_event.subscribe_url.blank?

      ALLOWED_AWS_ACCOUNTS.any? { |arn| sns_event.subscribe_url.include?(arn) }
    end

    private

    def local_bypass?
      Rails.env.development? || ENV.key?('IS_LOCAL_DOCKER_ENV')
    end

    def message_verifier
      @message_verifier ||= Aws::SNS::MessageVerifier.new
    end
  end
end

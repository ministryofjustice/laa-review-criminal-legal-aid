module Aws
  class SnsService
    ALLOWED_AWS_ACCOUNTS = [
      'arn:aws:sns:eu-west-2:754256621582:',
    ].freeze

    attr_reader :sns_event

    def initialize(sns_event:)
      @sns_event = sns_event
    end

    # NOTE: only supports '#create!' for now
    def call
      if sns_event.confirmation? && confirmation_allowed?
        sns_event.confirm!
        :ok
      elsif sns_event.notification?
        sns_event.create!
        :created
      else
        :forbidden
      end
    end

    def allowed?
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
      return false if sns_event.subscribe_url.blank?

      ALLOWED_AWS_ACCOUNTS.any? { |arn| sns_event.subscribe_url.include?(arn) }
    end

    private

    def message_verifier
      @message_verifier ||= Aws::SNS::MessageVerifier.new
    end
  end
end

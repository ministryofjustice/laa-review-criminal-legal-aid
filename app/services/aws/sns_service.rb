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
      @result =
        if confirmation?
          sns_event.confirm!
        elsif notification?
          sns_event.create!
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
      return false if sns_message.topic_arn.blank?

      ALLOWED_AWS_ACCOUNTS.any? { |arn| topic_arn.starts_with?(arn) }
    end

    def message_verifier
      @message_verifier ||= Aws::SNS::MessageVerifier.new
    end
  end
end

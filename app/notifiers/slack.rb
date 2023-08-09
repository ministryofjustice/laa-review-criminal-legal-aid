class Slack
  attr_reader :token, :channel

  def initialize(channel)
    @token = Rails.configuration.x.admin.slack_token
    @channel = channel
  end

  def post_message(_text); end
end

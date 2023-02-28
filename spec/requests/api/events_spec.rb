require 'rails_helper'

RSpec.describe 'Api::Events' do
  include_context 'with review'
  let(:sns_message_id) { SecureRandom.uuid }
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:message) do
    {
      event_name: 'apply.submission',
      data: {
        id: application_id,
        submitted_at: DateTime.parse('2022-10-27T14:09:11'),
        parent_id: nil
      }
    }
  end

  def do_request
    post('/api/events', params: body, headers: headers)
  end

  describe 'SNS Nofification callback' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'Notification',
        'x-amz-sns-message-id' => sns_message_id
      }
    end

    let(:body) do
      {
        'Type' => 'Notification',
        'MessageId' => sns_message_id,
        'TopicArn' => 'arn:aws:sns:us-west-2:123456789012:MyTopic',
        'Subject' => 'apply.submission',
        'Message' => message.to_json,
        'Timestamp' => '2012-05-02T00:54:06.655Z',
        'SignatureVersion' => '1',
        'Signature' => 'EXAMPLEw6JRN...',
        'SigningCertURL' => 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem',
        'UnsubscribeURL' => 'https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:123456789012:MyTopic:c9135db0-26c4-47ec-8998-413945fb5a96'
      }.to_json
    end

    it 'creates an ApplicationReceived event' do
      expect { do_request }.to change { review.state }.from(nil).to(:open)

      expect(response).to have_http_status :created
    end

    it 'is idempotent' do
      do_request
      expect { do_request }.not_to(change { review.state })

      expect(response).to have_http_status :ok
    end
  end

  describe 'SNS Nofification callback with raw_message_delivery' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'Notification',
        'x-amz-sns-message-id' => sns_message_id,
        'x-amz-sns-rawdelivery' => 'true'
      }
    end

    let(:body) { message.to_json }

    it 'creates an ApplicationReceived event' do
      expect { do_request }
        .to change { review.state }.from(nil).to(:open)
        .and change { review.submitted_at }.from(nil).to DateTime.parse('2022-10-27T14:09:11')

      expect(response).to have_http_status :created
    end
  end

  describe 'SNS Subscription Confirmation' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'SubscriptionConfirmation',
        'x-amz-sns-message-id' => sns_message_id
      }
    end

    let(:body) do
      {
        'Type' => 'SubscriptionConfirmation',
        'MessageId' => sns_message_id,
        'Token' => '2336412f37f...',
        'TopicArn' => 'arn:aws:sns:us-west-2:123456789012:MyTopic',
        'Message' => 'You have chosen to subscribe to the topic arn:aws:sns:us-west-2:123456789012:MyTopic.',
        'SubscribeURL' => 'https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&TopicArn=arn:aws:sns:us-west-2:123456789012:MyTopic&Token=2336412f37',
        'Timestamp' => '2012-04-26T20:45:04.751Z',
        'SignatureVersion' => '1',
        'Signature' => 'EXAMPLEpH+...',
        'SigningCertURL' => 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem'
      }.to_json
    end

    it 'confirms the subscription' do
      stub = stub_request(:get, 'https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&Token=2336412f37&TopicArn=arn:aws:sns:us-west-2:123456789012:MyTopic').to_return(
        status: 200, body: '', headers: {}
      )

      do_request
      expect(stub).to have_been_requested
      expect(response).to have_http_status :ok
    end
  end

  describe 'SNS unsubscribe notifcation' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'UnsubscribeConfirmation',
        'x-amz-sns-message-id' => sns_message_id
      }
    end

    let(:body) do
      {
        'Type' => 'UnsubscribeConfirmation'
      }
    end

    it 'returns okay' do
      do_request
      expect(response).to have_http_status :ok
    end
  end
end

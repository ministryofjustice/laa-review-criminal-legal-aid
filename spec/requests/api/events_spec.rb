require 'rails_helper'

RSpec.describe 'Api::Events' do
  let(:sns_message_id) { SecureRandom.uuid }

  let(:headers) do
    {
      'x-amz-sns-message-type' => 'Notification',
      'x-amz-sns-message-id' => sns_message_id
    }
  end

  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:notification_body) do
    {
      'Type' => 'Notification',
      'MessageId' => sns_message_id,
      'TopicArn' => 'arn:aws:sns:us-west-2:123456789012:MyTopic',
      'Subject' => 'apply.submission',
      'Message' => LaaCrimeSchemas.fixture(1.0).read,
      'Timestamp' => '2012-05-02T00:54:06.655Z',
      'SignatureVersion' => '1',
      'Signature' => 'EXAMPLEw6JRN...',
      'SigningCertURL' => 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem',
      'UnsubscribeURL' => 'https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:123456789012:MyTopic:c9135db0-26c4-47ec-8998-413945fb5a96'
    }
  end

  def do_request
    post('/api/events', params: notification_body, headers: headers)
  end

  def review
    Reviewing::LoadReview.call(application_id:)
  end

  describe 'SNS Nofification callback' do
    let(:review_state) { -> { Reviewing::LoadReview.call(application_id:).state } }

    it 'creates an ApplicationReceived event' do
      expect { do_request }.to change { review.state }.from(:submitted).to(:open)

      expect(response).to have_http_status :created
    end

    it 'idempotent' do
      do_request
      expect { do_request }.not_to(change { review.state })

      expect(response).to have_http_status :ok
    end
  end
end

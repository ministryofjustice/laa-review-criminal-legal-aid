require 'rails_helper'

RSpec.describe SnsEvent::ReceiveApplicationEvent do
  describe '#new' do
    context 'with valid params' do
      subject(:event) { described_class.new(sns_message:, headers:) }

      it 'extracts a request body and message from stringified JSON' do
        expect(event.request_body).to be_a Hash
        expect(event.message).to be_a Hash
      end
    end

    context 'with invalid params' do
      it 'rejects non-Hash headers' do
        expect { described_class.new(sns_message: sns_message, headers: '{}') }
          .to raise_error(ArgumentError, 'Headers must be an Enumerable type')
      end

      it 'extracts empty request body and message from non-stringified JSON' do
        event = described_class.new(sns_message: { message: { city: 'Bath' } }, headers: headers)

        expect(event.request_body).to be_empty
        expect(event.message).to be_empty
      end
    end
  end

  describe '#confirm!' do
    context 'when SubscribeURL is not present' do
      it 'does not attempt to confirm SNS topic subscription' do
        expect { described_class.new(sns_message:, headers:).confirm! }
          .to raise_error(ArgumentError, 'Cannot confirm SNS topic subscription without valid SubscribeURL')
      end
    end
  end

  describe '#valid?' do
    subject(:event) { described_class.new(sns_message:, headers:) }

    it { is_expected.to respond_to(:valid?) }
  end

  def sns_message
    @sns_message ||= {
      'Type' => 'Notificxation',
      'Token' => '2336412f37f',
      'MessageId' => SecureRandom.uuid,
      'TopicArn' => 'arn:aws:sns:eu-west-2:754256621582:ImportantMaatTopic',
      'Subject' => 'apply.submission',
      'Message' => { event_name: 'apply.submission' }.to_json,
      'Timestamp' => '2012-05-02T00:54:06.655Z',
      'SignatureVersion' => '1',
      'SigningCertURL' => 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem',
      'UnsubscribeURL' => 'https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-2:754256621582:MyTopic:c9135db0-26c4-47ec-8998-413945fb5a96'
    }.to_json
  end

  def headers
    @headers ||= {
      'x-amz-sns-message-type' => 'Notification',
      'x-amz-sns-message-id' => '7646a09f-d9c6-41c9-a219-9e46683c174b'
    }
  end
end

require 'rails_helper'
require 'base64'
require 'aws-sdk-sns'

RSpec.describe 'Api::Events' do
  include_context 'with review'

  let(:sns_message_id) { SecureRandom.uuid }
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:message) do
    {
      event_name: 'apply.submission',
      data: {
        id: application_id,
        submitted_at: Time.zone.parse('2022-10-27T14:09:11'),
        parent_id: 'ff32c3e6-a88e-4d3d-a595-5a11b0aea9ef',
        work_stream: Types::WorkStreamType['extradition'],
        reference: 123,
        application_type: Types::ApplicationType['initial']
      }
    }
  end

  def do_request
    private_key = OpenSSL::PKey::RSA.new(private_key_cert)
    signature = private_key.sign(OpenSSL::Digest.new('SHA1'), canonical_string(body))
    body['Signature'] = Base64.encode64(signature)

    post('/api/events', params: body.to_json, headers: headers)
  end

  # Signature generation on verify:
  # https://github.com/aws/aws-sdk-ruby/blob/version-3/gems/aws-sdk-sns/lib/aws-sdk-sns/message_verifier.rb
  def canonical_string(dict)
    aws_message_verifier.send(:canonical_string, dict)
  end

  def aws_message_verifier
    @aws_message_verifier ||= Aws::SNS::MessageVerifier.new
  end

  def public_key_cert
    @public_key_cert ||= Rails.root.join('spec/fixtures/files/certs/sns_certificate.pem').read
  end

  def private_key_cert
    @private_key_cert ||= Rails.root.join('spec/fixtures/files/certs/sns_key.pem').read
  end

  def standard_sns_message
    {
      'Type' => nil,
      'Token' => '2336412f37f',
      'MessageId' => nil,
      'TopicArn' => 'arn:aws:sns:eu-west-2:754256621582:ImportantMaatTopic',
      'Subject' => nil,
      'Message' => '',
      'Timestamp' => '2012-05-02T00:54:06.655Z',
      'SignatureVersion' => '1',
      'SigningCertURL' => 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem',
      'UnsubscribeURL' => 'https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-2:754256621582:MyTopic:c9135db0-26c4-47ec-8998-413945fb5a96'
    }
  end

  before do
    stub_request(
      :get,
      'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem'
    ).to_return(status: 200, body: public_key_cert, headers: {})

    stub_request(
      :get,
      'https://sns.us-west-2.amazonaws.com/BAD-PUBLIC-CERT.pem'
    ).to_return(status: 200, body: nil, headers: {})
  end

  describe 'SNS Nofification callback' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'Notification',
        'x-amz-sns-message-id' => sns_message_id
      }
    end

    let(:body) do
      standard_sns_message.merge(
        'Type' => 'Notification',
        'Subject' => 'apply.submission',
        'Message' => message.to_json
      )
    end

    it 'creates an ApplicationReceived event' do
      expect { do_request }.to change { review.state }.from(nil).to(:open)
                                                      .and change {
                                                             review.parent_id
                                                           }.from(nil).to('ff32c3e6-a88e-4d3d-a595-5a11b0aea9ef')
                                                                      .and change {
                                                                             review.work_stream
                                                                           }.from(nil).to('extradition')

      expect(response).to have_http_status :created
    end

    it 'is idempotent' do
      do_request
      expect { do_request }.not_to(change { review.state })

      expect(response).to have_http_status :ok
    end
  end

  # NOTE: When raw message delivery is enabled all SNS metadata is stripped
  # https://docs.aws.amazon.com/sns/latest/dg/sns-large-payload-raw-message-delivery.html
  describe 'SNS Nofification callback with raw_message_delivery' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'Notification',
        'x-amz-sns-message-id' => sns_message_id,
        'x-amz-sns-rawdelivery' => 'true'
      }
    end

    let(:body) { message }

    it 'is rejected' do
      expect { do_request }.not_to(change { review.state })

      expect(response).to have_http_status :unavailable_for_legal_reasons
    end
  end

  describe 'SNS Subscription Confirmation' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'SubscriptionConfirmation',
        'x-amz-sns-message-id' => sns_message_id
      }
    end

    context 'with allowed SubscribeURL' do
      let(:body) do
        standard_sns_message.merge(
          'Type' => 'SubscriptionConfirmation',
          'MessageId' => sns_message_id,
          'Message' => message.to_json,
          'SubscribeURL' => 'https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&Token=2336412f37&TopicArn=arn:aws:sns:eu-west-2:754256621582:MyTopic'
        )
      end

      it 'confirms the subscription' do
        stub = stub_request(:get, 'https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&Token=2336412f37&TopicArn=arn:aws:sns:eu-west-2:754256621582:MyTopic').to_return(
          status: 200, body: '', headers: {}
        )
        do_request

        expect(stub).to have_been_requested
        expect(response).to have_http_status :ok
      end
    end

    context 'with disallowed SubscribeURL' do
      let(:body) do
        standard_sns_message.merge(
          'Type' => 'SubscriptionConfirmation',
          'MessageId' => sns_message_id,
          'Message' => message.to_json,
          'SubscribeURL' => 'https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&Token=2336412f37&TopicArn=arn:aws:sns:eu-west-2:1234444:BadARN!'
        )
      end

      it 'does not confirm the subscription' do
        stub = stub_request(:get, 'https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&Token=2336412f37&TopicArn=arn:aws:sns:eu-west-4:123999:BadTopicARN!').to_return(
          status: 200, body: '', headers: {}
        )
        do_request

        expect(stub).not_to have_been_requested
        expect(response).to have_http_status :forbidden
      end
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
      standard_sns_message.merge(
        'Type' => 'UnsubscribeConfirmation',
        'MessageId' => sns_message_id,
        'Message' => {}.to_json
      )
    end

    it 'returns forbidden' do
      do_request
      expect(response).to have_http_status :forbidden
    end
  end

  describe 'SNS message unverified' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'Notification',
        'x-amz-sns-message-id' => sns_message_id
      }
    end

    let(:body) do
      standard_sns_message.merge(
        'Type' => 'Notification',
        'Subject' => 'apply.submission',
        'Message' => message.to_json,
        'SigningCertURL' => 'https://sns.us-west-2.amazonaws.com/BAD-PUBLIC-CERT.pem'
      )
    end

    it 'throws exception' do
      expect { do_request }.to raise_error(
        Aws::SNS::MessageVerifier::VerificationError,
        'The certificate does not match expected X509 PEM format.'
      )
    end
  end

  describe 'SNS message empty' do
    let(:headers) do
      {
        'x-amz-sns-message-type' => 'Notification',
        'x-amz-sns-message-id' => sns_message_id
      }
    end

    let(:body) { {} }

    it 'returns unprocessable entity' do
      post('/api/events', params: body.to_json, headers: headers)
      expect(response).to have_http_status :unprocessable_entity
    end
  end

  describe 'Unrecognised TopicArn' do
    let(:body) { standard_sns_message.merge('TopicArn' => 'arn:NotAMaatTopic') }

    it 'returns unauthorized' do
      do_request

      expect(response).to have_http_status :unauthorized
    end
  end
end

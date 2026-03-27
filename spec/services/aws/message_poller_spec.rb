require 'rails_helper'

# rubocop:disable Layout/LineLength, RSpec/MultipleMemoizedHelpers
RSpec.describe Aws::MessagePoller do
  subject(:message_poller) { described_class.new(queue: 'queue') }

  include_context 'with review'

  let(:application_id) { '3201a700-921c-4e8e-93b0-df9ff5fe7328' }
  let(:sqs_client) { instance_double(Aws::SQS::Client) }
  let(:sqs_response) { instance_double(Aws::SQS::Types::ReceiveMessageResult) }
  let(:queue_url_result) { instance_double(Aws::SQS::Types::GetQueueUrlResult) }

  let(:message) do
    Aws::SQS::Types::Message.new(
      message_id: '76fa523d-cbd5-4102-9fc7-8a175436a0ab',
      receipt_handle: 'receipt_handle',
      body: {
        Type: 'Notification',
        MessageId: '47b67962-8ffd-4f76-bbef-2baf35a51944',
        TopicArn: 'arn:aws:sns:us-east-1:000000000000:events-sns-topic-dev',
        Message: {
          event_name:,
          data:
        }.to_json,
        Timestamp: '2025-07-30T10:04:34.533Z',
        UnsubscribeURL: 'http://localhost.localstack.cloud:4566/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:000000000000:events-sns-topic-dev:69698939-6929-461b-8191-4c9c9bc890c5',
        MessageAttributes: { event_name: { Type: 'String', Value: event_name } },
        SignatureVersion: '1',
        Signature: 'IaJw8yqKPrgguJakJi2gWbe91QOk9FnDgo5Q1AEH9iJR/59oI8/p8y/HQVp0h8HomOjOB1ZZu1AcS6LpJydC3wk7LWN7swKEW9qD7ruqwcolvOXr3ocyqZNLebMUzrL94lI2TjgHrAeiq3PLLKE1rC/V1aXOpDSnIAL3OtNgtHEcxueTDYOzFnbydj3e2hcAuHEPfdXvEauDi3FC/8ZVBhK5Xabiwtec87L+9a+zO9mbe+BIICp4lOtHTgSO5pqxXvF77fN2GjROSdPul+F6qyS4uCkxaspcOtjJvtW8Uu5U9Ecqg/RWVkq7UkBRgPhsuIHapGoRZCapFO0SHVKo3w==',
        SigningCertURL: 'http://localhost.localstack.cloud:4566/_aws/sns/SimpleNotificationService-6c6f63616c737461636b69736e696365.pem'
      }.to_json
    )
  end

  let(:event_name) { 'apply.submission' }
  let(:data) do
    {
      id: application_id,
      submitted_at: '2025-07-30T10:04:34.276Z',
      parent_id: nil,
      work_stream: 'criminal_applications_team',
      application_type: 'initial',
      reference: 94
    }
  end

  before do
    allow(Aws::SQS::Client).to receive(:new).and_return(sqs_client)
    allow(sqs_client).to receive(:get_queue_url).and_return(queue_url_result)
    allow(queue_url_result).to receive(:queue_url).and_return('queue_url')
  end

  describe '#start!' do
    before do
      allow(sqs_client).to receive(:receive_message).and_return(sqs_response)
      allow(sqs_client).to receive(:delete_message)
      allow(sqs_response).to receive(:messages).and_return([message])
      allow(message_poller).to receive(:loop).and_yield # rubocop:disable RSpec/SubjectStub
      allow(Rails.logger).to receive(:warn)
    end

    it 'polls SQS queue for messages and deletes them' do # rubocop:disable RSpec/ExampleLength
      message_poller.start!

      expect(sqs_client).to have_received(:receive_message).with(
        queue_url: 'queue_url',
        message_system_attribute_names: ['SentTimestamp'],
        message_attribute_names: ['All'],
        max_number_of_messages: 10,
        wait_time_seconds: 20
      )
      expect(sqs_client).to have_received(:delete_message).with(queue_url: 'queue_url',
                                                                receipt_handle: 'receipt_handle')
    end

    context 'when event_name is apply.submission' do
      it 'creates an ApplicationReceived event' do
        expect { message_poller.start! }.to change { review.state }.from(nil).to(:open).and not_change { review.parent_id }.from(nil).and change { review.work_stream }.from(nil).to('criminal_applications_team')
      end

      it 'is idempotent' do
        message_poller.start!
        expect { message_poller.start! }.not_to(change { review.state })

        expect(Rails.logger).to have_received(:warn).with('Application already received')
      end
    end

    context 'when event_name is Deleting::Archived' do
      let(:event_name) { 'Deleting::Archived' }
      let(:data) do
        {
          id: application_id,
            application_type: 'initial',
            reference: 94,
            archived_at: '2026-02-11T09:00:00.000Z'
        }
      end

      it 'publishes a Deleting::Archived event to the event store' do
        expect { message_poller.start! }.to change {
          Rails.configuration.event_store.read.to_a.count { |e| e.event_type == 'Deleting::Archived' }
        }.by(1)
      end
    end

    context 'when event_name is Deleting::SoftDeleted' do
      let(:event_name) { 'Deleting::SoftDeleted' }
      let(:data) do
        {
          id: application_id,
           application_type: 'initial',
           reference: 94,
           soft_deleted_at: '2026-02-11T09:00:00.000Z',
           reason: 'retention_rule',
           deleted_by: 'system_automated'
        }
      end

      it 'publishes a Deleting::SoftDeleted event to the event store' do
        expect { message_poller.start! }.to change {
          Rails.configuration.event_store.read.to_a.count { |e| e.event_type == 'Deleting::SoftDeleted' }
        }.by(1)
      end
    end
  end
end
# rubocop:enable Layout/LineLength, RSpec/MultipleMemoizedHelpers

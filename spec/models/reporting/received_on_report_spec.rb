require 'rails_helper'

RSpec.describe Reporting::ReceivedOnReport do
  before do
    # Models specs do not have handers subscribed to the event store by default.
    # Here we subscribe the ReceivedOnReports handlers to the event store.
    ReceivedOnReports::Configuration.new.call(Rails.configuration.event_store)
  end

  describe '#total_open' do
    subject(:total_open) { record.total_open }

    context 'when new' do
      let(:record) { described_class.new }

      it { is_expected.to be_zero }
    end

    context 'with 100 received and 512 closed' do
      let(:record) { described_class.new(total_received: 100, total_closed: 51) }

      it { is_expected.to be 49 }
    end
  end

  it 'is a read only model' do
    expect(described_class.new).to be_readonly
  end

  describe 'updating with review events' do
    let(:application_id) { SecureRandom.uuid }
    let(:submitted_at) { 1.week.ago.to_s }
    let(:report) { described_class.find(BusinessDay.new(day_zero: submitted_at).date) }

    let(:command) { Reviewing::ReceiveApplication.new(application_id: SecureRandom.uuid, submitted_at: submitted_at) }

    context 'when a report does not exist for the given business day' do
      it 'a new report is created' do
        business_day = BusinessDay.new(day_zero: submitted_at).date
        expect { command.call }.to change { described_class.where(business_day:).count }.by(1)
      end
    end

    context 'when a report for the given business day exists' do
      before do
        stub_request(:get, "https://datastore-api-stub.test/api/v1/applications/#{application_id}")
        allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
          .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

        Reviewing::ReceiveApplication.call(application_id:, submitted_at:)
      end

      let(:user_id) { SecureRandom.uuid }

      describe 'a receive command' do
        it 'increments the total received' do
          expect { command.call }.to change { report.reload.total_received }.from(1).to(2)
        end
      end

      describe 'a mark as complete command' do
        let(:command) { Reviewing::Complete.new(application_id:, submitted_at:, user_id:) }

        it 'increments the total closed' do
          expect { command.call }.to change { report.reload.total_closed }.from(0).to(1)
        end
      end

      describe 'a send back command' do
        let(:command) do
          Reviewing::SendBack.new(application_id: application_id, submitted_at: submitted_at, user_id: user_id,
                                  return_details: { reason: 'evidence_issue', details: 'a' })
        end

        it 'increments the total closed' do
          expect { command.call }.to change { report.reload.total_closed }.from(0).to(1)
        end
      end
    end
  end
end

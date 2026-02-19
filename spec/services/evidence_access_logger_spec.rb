require 'rails_helper'

RSpec.describe EvidenceAccessLogger do
  let(:crime_application) { instance_double(CrimeApplication, id: '12345', assigned_to?: assigned) }
  let(:document) do
    instance_double(
      Document,
      content_type: 'application/pdf',
      filename: 'test.pdf',
      s3_object_key: 's3_key_123'
    )
  end
  let(:current_user) { instance_double(User, id: 'user_456', role: 'caseworker') }
  let(:assigned) { true }
  let(:timestamp) { Time.zone.parse('2024-01-15 10:30:00') }
  let(:logger_spy) { instance_spy(ActiveSupport::Logger) }

  before do
    allow(Time).to receive(:current).and_return(timestamp)
    allow(Rails).to receive(:logger).and_return(logger_spy)
  end

  describe '.log_view' do
    it 'logs evidence_viewed event with structured data' do
      described_class.log_view(crime_application:, document:, current_user:)

      expected_log = %r{evidence_viewed.*{"application_id":"12345","caseworker_id":"user_456",
                      "caseworker_role":"caseworker","assigned":"assigned",
                      "file_type":"application/pdf","timestamp":"2024-01-15T10:30:00Z"}}x

      expect(logger_spy).to have_received(:info).with(expected_log)
    end
  end

  describe '.log_download' do
    it 'logs evidence_downloaded event with structured data' do
      described_class.log_download(crime_application:, document:, current_user:)

      expected_log = %r{evidence_downloaded.*{"application_id":"12345","caseworker_id":"user_456",
                      "caseworker_role":"caseworker","assigned":"assigned",
                      "file_type":"application/pdf","timestamp":"2024-01-15T10:30:00Z"}}x

      expect(logger_spy).to have_received(:info).with(expected_log)
    end
  end

  describe 'assignment status' do
    context 'when user is assigned to application' do
      let(:assigned) { true }

      it 'logs assigned status' do
        described_class.log_view(
          crime_application:,
          document:,
          current_user:
        )

        expect(logger_spy).to have_received(:info).with(/assigned":"assigned"/)
      end
    end

    context 'when user is not assigned to application' do
      let(:assigned) { false }

      it 'logs not_assigned status' do
        described_class.log_view(
          crime_application:,
          document:,
          current_user:
        )

        expect(logger_spy).to have_received(:info).with(/assigned":"not_assigned"/)
      end
    end
  end

  describe 'caseworker roles' do
    %w[caseworker supervisor data_analyst].each do |role|
      context "when caseworker has #{role} role" do
        let(:current_user) { instance_double(User, id: 'user_456', role: role) }

        it "logs #{role} in caseworker_role" do
          described_class.log_view(
            crime_application:,
            document:,
            current_user:
          )

          expect(logger_spy).to have_received(:info).with(/caseworker_role":"#{role}"/)
        end
      end
    end
  end
end

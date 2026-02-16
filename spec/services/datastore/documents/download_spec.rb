require 'rails_helper'

RSpec.describe Datastore::Documents::Download do
  subject(:download_service) { described_class.new(document:, log_context:) }

  include_context 'when downloading a document'

  let(:document) { instance_double(Document, filename:, s3_object_key:) }
  let(:log_context) { { caseworker_id: 1, caseworker_ip: '123.0001' } }

  describe '#call' do
    before do
      allow(FeatureFlags).to receive(:view_evidence) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }
    end

    context 'when a document download link is retrieved successfully' do
      before do
        stub_request(:put, 'https://datastore-api-stub.test/api/v1/documents/presign_download')
          .with(body: expected_query)
          .to_return(status: 201, body: { url: presign_download_url }.to_json)
      end

      it 'returns a presigned download url' do
        expect(download_service.call.url).to eq(presign_download_url)
      end
    end

    context 'when there is a problem connecting to the API' do
      before do
        stub_request(:put, 'https://datastore-api-stub.test/api/v1/documents/presign_download')
          .with(body: expected_query)
          .to_return(status: 500)
      end

      it 'raises an DownloadError' do
        expect { download_service.call }.to raise_error Datastore::Documents::DownloadError
      end
    end

    context 'when the file name contains UTF-8 characters' do
      let(:filename) { 'Document 1 – Main Account 1-15 November.rtf' }
      let(:filename_safe) { 'Document_1___Main_Account_1-15_November.rtf' }
      let(:filename_escaped) { 'Document%201%20%E2%80%93%20Main%20Account%201-15%20November.rtf' }

      let(:expected_query) do
        {
          object_key: %r{123/.*},
          s3_opts: {
            expires_in: Datastore::Documents::Download::PRESIGNED_URL_EXPIRES_IN,
            response_content_disposition:
              "attachment; filename=#{filename_safe}; filename*= UTF-8''#{filename_escaped};"
          }
        }
      end

      before do
        stub_request(:put, 'https://datastore-api-stub.test/api/v1/documents/presign_download')
          .with(body: expected_query)
          .to_return(status: 201, body: { url: presign_download_url }.to_json)
      end

      it 'returns a presigned download url' do
        expect(download_service.call.url).to eq(presign_download_url)
      end
    end
  end
end

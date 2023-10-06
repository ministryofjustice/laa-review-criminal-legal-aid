require 'rails_helper'

RSpec.describe Datastore::Documents::Download do
  subject(:download_service) { described_class.new(document:) }

  include_context 'when downloading a document'

  let(:document) { instance_double(Document, filename:, s3_object_key:) }

  describe '#call' do
    context 'when a document download link is retrieved successfully' do
      before do
        stub_request(:put, 'https://datastore-api-stub.test/api/v1/documents/presign_download')
          .with(body: expected_query)
          .to_return(status: 201, body: { url: presign_download_url }.to_json)
      end

      it 'returns presign download url' do
        expect(download_service.call.url).to eq(presign_download_url)
      end
    end

    context 'when there is a problem connecting to the API' do
      before do
        stub_request(:put, 'https://datastore-api-stub.test/api/v1/documents/presign_download')
          .with(body: expected_query)
          .to_return(status: 500)
      end

      it 'returns false' do
        expect(download_service.call).to be(false)
      end
    end
  end
end

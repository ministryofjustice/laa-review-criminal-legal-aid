RSpec.shared_context 'when downloading a document' do
  let(:filename) { 'test.pdf' }
  let(:s3_object_key) { '123/abcdef1234' }

  let(:expected_query) do
    { object_key: %r{123/.*}, s3_opts: { expires_in: Datastore::Documents::Download::PRESIGNED_URL_EXPIRES_IN,
                                         response_content_disposition:  "attachment; filename=\"#{filename}\"" } }
  end

  let(:presign_download_url) do
    'https://localhost.localstack.cloud:4566/crime-apply-documents-dev/42/WtpJTOwsQ2?response-content-disposition=attachment%3B%20filename%3Dtest.pdf&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=test%2F20231005%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20231005T112229Z&X-Amz-Expires=15&X-Amz-SignedHeaders=host&X-Amz-Signature=ca6081d4060ab8fc692f53b1746740f13a6bf3e46a6df0cf0acc06ed2367084e'
  end

  let(:expected_return) { { status: 201, body: { url: presign_download_url }.to_json } }

  before do
    stub_request(:put, 'https://datastore-api-stub.test/api/v1/documents/presign_download')
      .with(body: expected_query)
      .to_return(expected_return)
  end
end

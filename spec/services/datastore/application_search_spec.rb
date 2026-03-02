require 'rails_helper'

RSpec.describe Datastore::ApplicationSearch do
  subject(:search) { described_class.new }

  describe '#by_application_ids' do
    let(:application_ids) { [SecureRandom.uuid, SecureRandom.uuid] }

    let(:search_response) do
      {
        pagination: { total_count: 2, total_pages: 1, limit_value: 2 },
        records: [
          { resource_id: application_ids[0], reference: 1_000_001 },
          { resource_id: application_ids[1], reference: 1_000_002 }
        ]
      }.deep_stringify_keys
    end

    before do
      stub_request(:post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches")
        .with(
          body: {
            search: { application_id_in: application_ids },
            pagination: { per_page: application_ids.size, page: 1 }
          }
        )
        .to_return(status: 200, body: search_response.to_json)
    end

    # rubocop:disable RSpec/ExampleLength
    it 'posts to the searches endpoint with the application ids' do
      search.by_application_ids(application_ids)

      expect(WebMock).to have_requested(:post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches")
        .with(
          body: {
            search: { application_id_in: application_ids },
            pagination: { per_page: application_ids.size, page: 1 }
          },
          headers: { 'Content-Type' => 'application/json' }
        )
    end
    # rubocop:enable RSpec/ExampleLength

    it 'returns the search results' do
      results = search.by_application_ids(application_ids)

      expect(results.size).to eq(2)
    end

    it 'sets the pagination per_page to the number of application ids' do
      search.by_application_ids(application_ids)

      expect(WebMock).to have_requested(:post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches")
        .with(body: hash_including(pagination: { per_page: 2, page: 1 }))
    end
  end
end

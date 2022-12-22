RSpec.shared_context 'when search results are returned', shared_context: :metadata do
  let(:datastore_search) do
    DatastoreApi::Requests::SearchApplications
  end

  let(:search_response) do
    pagination = { total_pages: 1, current_page: 1, total_count: 2 }.stringify_keys

    results = [
      ApplicationSearchResult.new(
        applicant_name: 'Kit Pound',
        resource_id: '696dd4fd-b619-4637-ab42-a5f4565bcf4a',
        reference: 120_398_120,
        status: 'submitted',
        submitted_at: '2022-10-27T14:09:11.000+00:00'
      ),
      ApplicationSearchResult.new(
        applicant_name: 'Don Jones',
        resource_id: '1aa4c689-6fb5-47ff-9567-5eee7f8ac2cc',
        reference: 1_230_234_359,
        status: 'submitted',
        submitted_at: '2022-11-14T16:58:15.000+00:00'
      )
    ]

    DatastoreApi::Decorators::PaginatedCollection.new(
      results, pagination
    )
  end

  before do
    allow(datastore_search).to receive(:new) {
      instance_double(
        datastore_search,
        call: search_response
      )
    }

    visit '/'
    click_on 'Search'
  end

  def assert_api_searched_with_filter(*params)
    expect(datastore_search).to have_received(:new).with(
      ApplicationSearchFilter.new(**Hash[*params]).as_json
    ) {
      instance_double(
        DatastoreApi::Requests::SearchApplications, call: []
      )
    }
  end
end

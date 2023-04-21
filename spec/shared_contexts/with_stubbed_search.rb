RSpec.shared_context 'with stubbed search', shared_context: :metadata do
  let(:stubbed_search_results) do
    [
      ApplicationSearchResult.new(
        applicant_name: 'Kit Pound',
        resource_id: '696dd4fd-b619-4637-ab42-a5f4565bcf4a',
        reference: 120_398_120,
        status: 'submitted',
        submitted_at: '2022-10-27T14:09:11.000+00:00'
      ),
      ApplicationSearchResult.new(
        applicant_name: 'Don JONES',
        resource_id: '1aa4c689-6fb5-47ff-9567-5eee7f8ac2cc',
        reference: 1_230_234_359,
        status: 'submitted',
        submitted_at: '2022-11-11T16:58:15.000+00:00'
      )
    ]
  end

  let(:http_client) { instance_double(DatastoreApi::HttpClient) }

  let(:datastore_response) do
    pagination = Pagination.new(
      total_count: stubbed_search_results.size,
      total_pages: 1,
      limit_value: 50
    ).to_h

    records = stubbed_search_results.map(&:to_h)

    { pagination:, records: }.deep_stringify_keys
  end

  before do
    allow(http_client).to receive(:post) { datastore_response }
    #
    # Temporarily allow any instance of.
    # TODO remove when datastore api client has been updated.
    #
    # rubocop:disable RSpec::AnyInstance
    allow_any_instance_of(ApplicationSearch).to receive(:http_client) { http_client }
    # rubocop:enable RSpec::AnyInstance
  end

  def assert_api_searched_with_filter(*params, sorting: Sorting.new, pagination: Pagination.new)
    expect(http_client).to have_received(:post).with(
      '/searches',
      {
        search: ApplicationSearchFilter.new(**Hash[*params]).datastore_params,
        sorting: sorting.to_h,
        pagination: pagination.datastore_params
      }
    )
  end
end

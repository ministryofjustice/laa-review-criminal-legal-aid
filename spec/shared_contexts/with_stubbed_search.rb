RSpec.shared_context 'with stubbed search', shared_context: :metadata do
  let(:application_type) { 'initial' }

  let(:stubbed_search_results) do
    [
      ApplicationSearchResult.new(
        applicant_name: 'Kit Pound',
        resource_id: '696dd4fd-b619-4637-ab42-a5f4565bcf4a',
        reference: 120_398_120,
        status: 'submitted',
        work_stream: 'extradition',
        submitted_at: '2022-10-27T14:09:11.000+00:00',
        parent_id: nil,
        case_type: 'summary_only',
        application_type: 'initial',
        means_passport: ['on_benefit_check']
      ),
      ApplicationSearchResult.new(
        applicant_name: 'Don JONES',
        resource_id: '1aa4c689-6fb5-47ff-9567-5eee7f8ac2cc',
        reference: 1_230_234_359,
        work_stream: 'extradition',
        status: 'submitted',
        submitted_at: '2022-11-11T16:58:15.000+00:00',
        parent_id: nil,
        case_type: 'summary_only',
        application_type: 'initial',
        means_passport: ['on_benefit_check']
      ),
      ApplicationSearchResult.new(
        applicant_name: 'Jessica Rhode',
        resource_id: '012a553f-e9b7-4e9a-a265-67682b572fd0',
        reference: 120_398_120,
        status: 'submitted',
        work_stream: 'extradition',
        submitted_at: '2022-10-27T14:09:11.000+00:00',
        parent_id: 'parent_id_uuid',
        case_type: 'summary_only',
        application_type: application_type,
        means_passport: ['on_benefit_check']
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
    stub_request(
      :post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches"
    ).and_return(body: datastore_response.to_json)
  end

  def expect_datastore_to_have_been_searched_with(*params, sorting: nil, pagination: Pagination.new, number_of_times: 1)
    sorting ||= ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending')
    expect(WebMock).to have_requested(:post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches").with(
      body: {
        search: Hash[*params],
        sorting: sorting.to_h,
        pagination: pagination.datastore_params
      },
      headers: { 'Content-Type' => 'application/json' }
    ).times(number_of_times)
  end

  def expect_datastore_not_to_have_been_searched
    expect(WebMock).not_to have_requested(:post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches")
  end
end

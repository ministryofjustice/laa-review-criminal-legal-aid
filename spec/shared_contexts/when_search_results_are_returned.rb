RSpec.shared_context 'when search results are returned', shared_context: :metadata do
  include_context 'with stubbed search'

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

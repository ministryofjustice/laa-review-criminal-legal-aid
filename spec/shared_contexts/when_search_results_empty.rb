RSpec.shared_context 'when search results empty', shared_context: :metadata do
  let(:datastore_search) do
    DatastoreApi::Requests::SearchApplications
  end

  before do
    allow(datastore_search).to receive(:new) {
      instance_double(datastore_search, call: [])
    }

    visit '/'
    click_on 'Search'
    click_button 'Search'
  end
end

RSpec.shared_context 'when search results empty', shared_context: :metadata do
  include_context 'with stubbed search'

  let(:stubbed_search_results) { [] }
end

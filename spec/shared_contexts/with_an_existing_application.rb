RSpec.shared_context 'with an existing application', shared_context: :metadata do
  include_context 'with stubbed search'

  before do
    visit open_crime_applications_path
  end

  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
end

require 'rails_helper'

RSpec.describe 'Reference number' do
  include_context 'with stubbed search'
  let(:reference_number) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
    visit '/'
    visit crime_application_path(reference_number)
  end

  it 'has the copy link for the reference number' do
    expect(page).to have_content('Copy')
  end
end
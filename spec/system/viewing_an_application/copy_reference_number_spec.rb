require 'rails_helper'

RSpec.describe 'Reference number', rack_test: false do
  include_context 'with stubbed search'
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
    visit '/'
    visit crime_application_path(application_id)
  end

  it 'has the copy link for the reference number' do
    expect(page).to have_content('Copy')
  end

  describe 'click link' do
    it 'copies the reference number to the system clipboard when clicked' do
      # get the reference reference number from the page
      # google rspec get text from <p> html element
      # page_value = code to get the refnum from page
      #
      # click the Copy link
      # google how to click link with rspec, or look at other specs
      #
      # copied_value = code to get the value out of the the system clipboard
      # google how to get a value out of the the system clipboard with rspec
      #
      # expect(copied_value).to be(the_value_we_got_from_the_page)
    end
  end
end

require 'rails_helper'

RSpec.describe 'Missing Report' do
  it 'shows a not found error' do
    visit '/'
    visit report_path(:not_a_report)

    expect(page).to have_content 'Page not found'
  end
end

require 'rails_helper'

RSpec.describe 'Missing Report' do
  let(:current_user_can_manage_others) { false }
  let(:current_user_role) { UserRole::DATA_ANALYST }

  it 'shows a not found error' do
    visit '/'
    visit reporting_user_report_path(:not_a_report)

    expect(page).to have_http_status(:not_found)
  end
end

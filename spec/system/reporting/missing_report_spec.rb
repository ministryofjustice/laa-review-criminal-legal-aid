require 'rails_helper'

RSpec.describe 'Missing Report' do
  let(:current_user_can_manage_others) { false }
  let(:current_user_role) { UserRole::DATA_ANALYST }

  it 'shows a not found error' do
    visit '/'
    visit report_path(:not_a_report)

    expect_forbidden
  end
end

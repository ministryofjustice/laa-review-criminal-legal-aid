require 'rails_helper'

RSpec.describe 'Missing Report' do
  let(:current_user_can_manage_others) { false }
  let(:current_user_role) { UserRole::DATA_ANALYST }

  it 'shows a not found error' do
    visit '/'
    visit reporting_user_report_path(:not_a_report)

    expect(page).to have_http_status(:forbidden)
  end

  describe 'missing temporal report interval' do
    it 'shows a not found error' do
      visit '/'
      interval = 'daily'
      report_type = 'caseworker_report'
      period = '2023-08-01'

      visit reporting_temporal_report_path(
        interval:, report_type:, period:
      )

      expect(page).to have_http_status(:not_found)
    end
  end
end

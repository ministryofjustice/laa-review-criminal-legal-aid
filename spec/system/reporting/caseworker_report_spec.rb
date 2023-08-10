require 'rails_helper'

RSpec.describe 'Caseworker Report' do
  before do
    visit '/'
    visit report_path(:caseworker_report)
  end

  context 'when logged in user is caseworker' do
    it 'renders "Page not" found' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Page not found')
      expect(page).to have_http_status(:not_found)
    end
  end

  context 'when logged in as a supervisor' do
    let(:current_user_role) { UserRole::SUPERVISOR }

    it 'renders the caseworker report' do
      expect(page).to have_text(
        'Number of times applications were assigned to, unassigned from, and closed by a given caseworker'
      )
      expect(page).to have_http_status(:ok)
    end
  end
end

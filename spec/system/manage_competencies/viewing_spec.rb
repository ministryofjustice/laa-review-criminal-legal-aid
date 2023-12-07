require 'rails_helper'

RSpec.describe 'Manage Competencies Dashboard' do
  context 'when user does not have access to manage competencies' do
    before do
      visit manage_competencies_root_path
    end

    it 'redirects to "Access to this service is restricted"' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Access to this service is restricted')
    end
  end

  context 'when user does have access to manage competencies' do
    let(:current_user_role) { UserRole::SUPERVISOR }
    let(:caseworker) do
      User.create!(email: 'test@example.com', first_name: 'Test', last_name: 'Testing',
                   auth_subject_id: SecureRandom.uuid)
    end

    before do
      caseworker
      visit manage_competencies_root_path
    end

    it 'includes the page heading' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq('Manage competencies')
    end

    it 'includes the correct table headings' do
      column_headings = page.first('.govuk-table thead tr').text.squish

      expect(column_headings).to eq('Name Competencies History')
    end

    it 'shows the correct table content' do
      first_data_row = page.first('.govuk-table tbody tr').text
      expect(first_data_row).to eq(['Test Testing No competencies View history'].join(' '))
    end

    context 'when clicking links' do
      it 'redirects to the edit competency form page' do
        expect { click_on('No competencies') }.to change { page.current_path }
          .from(manage_competencies_root_path).to(edit_manage_competencies_caseworker_competency_path(caseworker))
      end

      it 'redirects to the competency history page' do
        expect { click_on('View history') }.to change { page.current_path }
          .from(manage_competencies_root_path).to(manage_competencies_history_path(caseworker))
      end
    end

    it_behaves_like 'a paginated page', path: '/manage_competencies?page=2'

    it_behaves_like 'an ordered user list' do
      let(:path) { manage_competencies_root_path }
      let(:expected_order) { ['Arthur Sample', 'Hassan Example', 'Hassan Sample', 'Test Testing'] }
      let(:column_num) { 1 }
    end
  end
end

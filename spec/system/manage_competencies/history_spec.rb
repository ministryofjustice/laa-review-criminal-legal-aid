require 'rails_helper'

RSpec.describe 'View caseworker competencies history' do
  context 'when user does have access to manage competencies' do
    let(:current_user_role) { UserRole::SUPERVISOR }
    let(:caseworker) do
      User.create!(email: 'test@example.com', first_name: 'Test', last_name: 'Testing',
                   auth_subject_id: SecureRandom.uuid)
    end

    before do
      caseworker
      visit manage_competencies_history_path(caseworker)
    end

    it 'includes the page heading' do
      heading_text = page.first('.govuk-heading-xl').text
      expect(heading_text).to eq("Test Testing's competency history")
    end

    it 'shows the correct table content when there is no history' do
      no_history_text = page.first('.govuk-body').text
      expect(no_history_text).to eq('There is no history')
    end

    context 'when there is history' do
      before do
        travel_to Time.zone.local(2023, 11, 13, 10, 0o4, 44)

        visit edit_manage_competencies_caseworker_competency_path(caseworker)
        check 'CAT 2'
        click_on 'Save'

        visit edit_manage_competencies_caseworker_competency_path(caseworker)
        uncheck 'CAT 2'
        click_on 'Save'

        visit manage_competencies_history_path(caseworker)
      end

      it 'includes the correct table headings' do
        column_headings = page.first('.govuk-table thead tr').text.squish

        expect(column_headings).to eq('When What Supervisor')
      end

      it 'shows the correct table content' do
        first_data_row = page.first('tbody tr.govuk-table__row:nth-of-type(1)').text
        expected_event = ['13 Nov 2023 10:04am Competencies set to no competencies Joe EXAMPLE'].join(' ')
        expect(first_data_row).to eq(expected_event)

        second_data_row = page.first('tbody tr.govuk-table__row:nth-of-type(2)').text
        expected_event = ['13 Nov 2023 10:04am Competencies set to CAT 2 Joe EXAMPLE'].join(' ')
        expect(second_data_row).to eq(expected_event)
      end
    end
  end
end

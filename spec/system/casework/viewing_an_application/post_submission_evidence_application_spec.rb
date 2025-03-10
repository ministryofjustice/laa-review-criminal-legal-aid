require 'rails_helper'

RSpec.describe 'Viewing an application unassigned, open, post submission evidence application' do
  let(:crime_application_id) { '21c37e3e-520f-46f1-bd1f-5c25ffc57d70' }
  let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'post_submission_evidence').read) }

  before do
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{crime_application_id}"
    ).to_return(body: application_data.to_json, status: 200)

    visit crime_application_path(crime_application_id)
  end

  it 'includes the application type' do
    expect(page).to have_content('Post submission evidence')
  end

  context 'with relevant client details information' do
    it 'displays name details' do
      expect(page).to have_content('First name Kit')
      expect(page).to have_content('Last name Pound')
    end

    it 'displays other name details' do
      expect(page).to have_content('Other names None')
    end

    it 'displays date of birth' do
      expect(page).to have_content('Date of birth 09/06/2001')
    end

    it 'does not display NI number' do
      expect(page).to have_no_content('National Insurance number')
    end

    it 'does not display telephone number' do
      expect(page).to have_no_content('UK Telephone number')
    end

    it 'does not display address information' do
      expect(page).to have_no_content('Home address')
      expect(page).to have_no_content('Correspondence address')
    end

    it 'does not display partner information' do
      expect(page).to have_no_content('Partner')
    end
  end

  context 'without standard application sections' do
    it 'does not display case details' do
      expect(page).to have_no_content('Case details')
    end

    it 'does not display offence details' do
      expect(page).to have_no_content('Offence')
    end

    it 'does not display co-defendants details' do
      expect(page).to have_no_content('Co-defendants')
    end

    it 'does not display interest of justice details' do
      expect(page).to have_no_content('Justification for legal aid')
    end
  end

  context 'with post submission evidence' do
    subject(:files_card) do
      page.find('h2.govuk-summary-card__title', text: 'Files')
          .ancestor('div.govuk-summary-card')
    end

    it 'displays post submission evidence section title' do
      expect(page).to have_content('Post submission evidence')
      expect(page).to have_no_content('Supporting evidence')
    end

    it 'shows a link to download the supporting evidence' do
      within(files_card) do |card|
        expect(card).to have_summary_row 'test.pdf', 'Download file (pdf, 12 Bytes)'
      end
    end
  end

  context 'when viewing application history of a completed pse' do
    before do
      click_on('Application history')
    end

    it 'includes the submission event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Monday 24 Oct 10:50am John Doe Post submission evidence submitted')
    end

    it 'includes the assigned event' do
      click_on('Assign to your list')
      click_on('Application history')

      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Joe EXAMPLE Post submission evidence assigned to Joe EXAMPLE')
    end

    context 'with a completed pse application' do
      include_context 'with a completed application'

      before do
        visit crime_application_path(crime_application_id)
        click_on('Application history')
      end

      it 'includes the completed event' do
        first_row = page.first('.app-dashboard-table tbody tr').text
        expect(first_row).to match('Fred Smitheg Post submission evidence completed')
      end
    end
  end

  context 'when reviewing application' do
    it 'does not show the following CTAs' do
      expect(page).to have_no_content('Mark as ready for MAAT')
      expect(page).to have_no_content('Send back to provider')
    end

    it 'does show the mark as complete button' do
      expect(page).to have_no_content('Mark as complete')
    end
  end
end

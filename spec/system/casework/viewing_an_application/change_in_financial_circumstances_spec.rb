require 'rails_helper'

RSpec.describe 'Viewing an application unassigned, open, change in financial circumstances application' do
  let(:crime_application_id) { '98ab235c-f125-4dcb-9604-19e81782e53b' }
  let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'change_in_financial_circumstances').read) }

  before do
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{crime_application_id}"
    ).to_return(body: application_data.to_json, status: 200)

    visit crime_application_path(crime_application_id)
  end

  it 'includes the application type' do
    expect(page).to have_content('Change in financial circumstances')
  end

  context 'without not-asked details' do
    it 'does not display overall offence class' do
      expect(page).to have_no_content('Overall offence class')
    end

    it 'does not display first court hearing details' do
      expect(page).to have_no_content('First court hearing the case')
    end

    it 'does not display next court hearing details' do
      expect(page).to have_no_content('Next court hearing the case')
    end

    it 'does not display next court date' do
      expect(page).to have_no_content('Date of next hearing')
    end

    it 'does not display offence details' do
      expect(page).to have_no_content('Offence')
    end

    it 'does not display interest of justice details' do
      expect(page).to have_no_content('Justification for legal aid')
    end
  end
end

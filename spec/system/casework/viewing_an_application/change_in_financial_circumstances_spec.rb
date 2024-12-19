require 'rails_helper'

RSpec.describe 'Viewing an application unassigned, open, change in financial circumstances application' do
  include_context 'with stubbed application'

  let(:crime_application_id) { '98ab235c-f125-4dcb-9604-19e81782e53b' }
  let(:fixture_name) { 'change_in_financial_circumstances' }

  before do
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{crime_application_id}"
    ).to_return(body: application_data.to_json, status: 200)

    visit crime_application_path(crime_application_id)
  end

  section_titles = [
    'About the provider',
    'Application details',
    'Bank account',
    'Benefits: partner',
    'Benefits: client',
    'Capital: Assets',
    'Capital: Savings and investments',
    'Case details and offences',
    'Case details',
    'Client details',
    'Declarations',
    'Declarations',
    'Details entered for date stamp',
    'Employment: client',
    'Files',
    'Further information',
    'Housing payments',
    'Income',
    'National Savings Certificate',
    'Other capital',
    'Other outgoings',
    'Other sources of income',
    'Other work benefits: client',
    'Other work benefits: partner',
    'Outgoings',
    'Overview',
    'Partner details',
    'Employment: partner',
    'Passporting benefit check: client',
    'Payments: partner',
    'Payments: client',
    'Payments the client makes',
    'Premium Bonds',
    'Provider details',
    'Residential property',
    'Self assessment: client',
    'Self assessment: partner',
    'Supporting evidence and information',
    'Trust funds: client',
    'Trust funds: partner',
    'Unit trust',
    'We asked the provider to upload:',
  ]

  it 'shows applicant name' do
    expect(page).to have_selector 'h1', text: 'Kit Pound', exact_text: true
  end

  it 'shows expected sections', :aggregate_failures do
    section_titles.each do |title|
      expect(page).to have_selector 'h2', text: title, exact_text: true
    end
  end

  it 'shows the application type' do
    expect(page).to have_content('Change in financial circumstances')
  end

  describe '#date_stamp_context' do
    context 'when it is unavailable' do
      let(:application_data) do
        JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
          'date_stamp_context' => nil
        )
      end

      it 'does not show date stamp details' do
        expect(page).not_to have_content('Details entered for date stamp')
      end
    end

    context 'when attributes are missing' do
      let(:application_data) do
        data = super()

        # first_name, last_name deliberately removed
        data['date_stamp_context'] = {
          'date_of_birth' => '2005-06-09',
        }

        data
      end

      it 'shows missing attributes as blank' do
        expected_details = [
          "First name\n",
          "Last name\n",
          'Date of birth 09/06/2005 Changed after date stamp',
        ]

        expected_details.each do |detail|
          expect(page).to have_content(detail)
        end
      end
    end

    context 'when it is changed' do
      let(:application_data) do
        super().deep_merge(
          'date_stamp_context' => {
            'first_name' => 'Rodney',
            'last_name' => 'Trotter',
            'date_of_birth' => '2005-06-09',
          }
        )
      end

      it 'shows date stamp details with changed tag' do
        expected_details = [
          'First name Rodney Changed after date stamp',
          'Last name Trotter Changed after date stamp',
          'Date of birth 09/06/2005 Changed after date stamp',
        ]

        expected_details.each do |detail|
          expect(page).to have_content(detail)
        end
      end
    end
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

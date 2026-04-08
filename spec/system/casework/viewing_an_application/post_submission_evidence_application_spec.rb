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
      expect(page).to have_selector('h2', text: 'Post submission evidence')
      expect(page).to have_no_selector('h2', text: 'Supporting evidence')
    end

    it 'shows a link to download the supporting evidence' do
      within(files_card) do
        expect(page).to have_link('View')
        expect(page).to have_link('Download file (pdf, 12 Bytes)')
      end
    end
  end

  context 'when viewing application history of a completed pse' do
    before do
      allow(FeatureFlags).to receive(:reference_history) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }

      click_on('Application history')
    end

    it 'includes the submission event' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Monday 24 Oct 2022 10:50am John Doe Post submission evidence submitted')
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

  context 'when reference_history feature flag is enabled' do
    let(:pse_id) { 'cccccccc-cccc-4ccc-8ccc-cccccccccccc' }
    let(:pse_reference) { 111_222_333 }
    let(:fred_user) do
      User.create(
        first_name: 'Fred',
        last_name: 'Smitheg',
        auth_oid: SecureRandom.uuid,
        email: 'Fred.Smitheg@justice.gov.uk'
      )
    end

    before do
      allow(FeatureFlags).to receive(:reference_history) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }

      pse_data = JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'post_submission_evidence').read).deep_merge(
        'id' => pse_id,
        'parent_id' => nil,
        'reference' => pse_reference,
        'application_type' => 'post_submission_evidence',
        'submitted_at' => '2022-10-24T10:50:00.000Z'
      )

      stub_request(:get, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{pse_id}")
        .to_return(body: pse_data.to_json, status: 200)

      Reviewing::ReceiveApplication.new(
        application_id: pse_id,
        parent_id: nil,
        work_stream: 'criminal_applications_team',
        application_type: 'post_submission_evidence',
        submitted_at: Time.zone.parse('2022-10-24T10:50:00.000Z'),
        reference: pse_reference
      ).call
    end

    it 'shows ordinal position for post submission evidence applications in assignment event' do
      Assigning::AssignToUser.new(
        user_id: fred_user.id,
        to_whom_id: fred_user.id,
        assignment_id: pse_id,
        reference: pse_reference
      ).call

      visit history_crime_application_path(pse_id)

      expect(page).to have_content('Post submission evidence 1 assigned to Fred Smitheg')
    end

    it 'shows ordinal position in submission event' do
      visit history_crime_application_path(pse_id)

      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('John Doe Post submission evidence 1 submitted')
    end
  end
end

require 'rails_helper'

RSpec.describe 'Viewing an application unassigned, open application' do
  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:application_data) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }

  before do
    stub_request(
      :get,
      "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/applications/#{application_id}"
    ).to_return(body: application_data.to_json, status: 200)

    Reviewing::ReceiveApplication.call(
      application_id: application_id,
      submitted_at: '2022-10-24T09:50:04.000+00:00',
      parent_id: nil
    )

    visit '/'
    visit crime_application_path(application_id)
  end

  it 'shows the open status badge' do
    badge = page.all('.govuk-tag').last.text

    expect(badge).to match('Open')
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('crime_applications.show.page_title')
  end

  it 'includes the copy reference link' do
    expect(page).to have_content('Copy reference number')
  end

  it 'includes the date received' do
    expect(page).to have_content('Date received: 24/10/2022')
  end

  it 'includes the application type' do
    expect(page).to have_content('Initial application')
  end

  context 'when date stamp is earlier than date received' do
    let(:application_data) { super().deep_merge('date_stamp' => '2022-11-21T16:57:51.000+00:00') }

    it 'includes the correct date stamp' do
      expect(page).to have_content('Date stamp 21/11/2022')
    end
  end

  it 'includes the applicant details' do
    expect(page).to have_content('AJ 12 34 56 C')
  end

  it 'shows that the application is unassigned' do
    expect(page).to have_content('Assigned to: no one')
  end

  it 'includes button to assign' do
    expect(page).to have_content('Assign to your list')
  end

  it 'does not show the CTAs' do
    expect(page).not_to have_content('Mark as completed')
  end

  context 'with interest of justice reason' do
    it 'shows reason' do
      expect(page).to have_content('Loss of liberty')
    end
  end

  context 'with ioj passport' do
    let(:application_data) { super().deep_merge('ioj_passport' => ['on_age_under18']) }

    it 'shows passport reason' do
      expect(page).to have_content('Client is under 18')
    end
  end

  # rubocop:disable Layout/LineLength
  context 'with offence class not provided' do
    it 'does shows the class not determined badge' do
      table_body = find(:xpath,
                        "//table[@class='govuk-table app-dashboard-table govuk-!-margin-bottom-9']//tr[contains(td[1], 'Non-listed offence, manually entered')]")

      expect(table_body).to have_content('Class not determined')
    end

    it 'displays undetermined overall offence class' do
      expect(page).to have_content('Overall offence class Undetermined')
    end
  end

  context 'with offence class provided' do
    let(:application_data) do
      super().deep_merge('case_details' => { 'offence_class' => 'C',
                                              'offences' => [{ 'name' => 'Robbery',
                                                              'offence_class' => 'C',
                                                              'passportable' => true,
                                                              'dates' => [{
                                                                'date_from' => '2020-12-12',
                                                                      'date_to' => nil
                                                              }] }] })
    end

    it 'does show the offence class' do
      row = first(:xpath,
                  "//table[@class='govuk-table app-dashboard-table govuk-!-margin-bottom-9']//tr[contains(td[1], 'Robbery')]")

      expect(row).to have_content('Class C')
    end

    it 'displays calculated overall offence class' do
      expect(page).to have_content('Overall offence class Class C')
    end
  end
  # rubocop:enable Layout/LineLength

  context 'with optional fields not provided' do
    let(:application_data) do
      super().deep_merge('client_details' => { 'applicant' => { 'home_address' => nil, 'telephone_number' => nil } })
    end

    it 'shows that the URN was not provided' do
      expect(page).to have_content('Unique reference number Not provided')
    end

    it 'shows that other names were not provided' do
      expect(page).to have_content('Other names Not provided')
    end

    it 'shows that the client telephone number was not provided' do
      expect(page).to have_content('UK Telephone number Not provided')
    end

    it 'shows that the client home address was not provided' do
      expect(page).to have_content('Home address Not provided')
    end
  end
end

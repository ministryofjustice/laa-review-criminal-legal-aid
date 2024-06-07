require 'rails_helper'

RSpec.describe 'Viewing an application unassigned, open application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  it 'includes the page title' do
    expect(page).to have_content I18n.t('casework.crime_applications.show.page_title')
  end

  it 'shows the open status badge' do
    badge = page.first('.govuk-tag.govuk-tag--blue').text

    expect(badge).to match('Open')
  end

  it 'includes the copy reference link' do
    expect(page).to have_content('Copy reference number')
  end

  context 'with URN provided' do
    let(:application_data) do
      super().deep_merge('case_details' => { 'urn' => '12345' })
    end

    it 'includes the copy urn link' do
      expect(page).to have_content('12345 Copy URN')
    end
  end

  it 'shows that the application is unassigned' do
    expect(page).to have_content('Assigned to: no one')
  end

  it 'includes button to assign' do
    expect(page).to have_content('Assign to your list')
  end

  it 'includes the date received' do
    expect(page).to have_content('Date received: 24/10/2022')
  end

  it 'includes the application type' do
    expect(page).to have_content('Initial application')
  end

  describe 'showing the means tested value' do
    subject(:means_tested_badge) do
      find('.govuk-summary-list__key',
           text: 'Is application subject to means test')
        .sibling('.govuk-summary-list__value')
    end

    context 'when the application is means passported' do
      it 'shows the blue passported badge' do
        expect(means_tested_badge).to have_content('Passported')
        expect(means_tested_badge).to have_css('.govuk-tag--blue')
      end
    end

    context 'when the application is not means passported' do
      let(:application_data) { super().merge('means_passport' => []) }

      it 'shows the red undetermined badge' do
        expect(means_tested_badge).to have_content('Undetermined')
        expect(means_tested_badge).to have_css('.govuk-tag--red')
      end
    end
  end

  describe 'showing the passporting benefit' do
    context 'when the application has a passporting benefit' do
      it 'shows the benefit type' do
        expect(page).to have_content('Passporting Benefit Universal Credit')
      end

      context 'when the benefit type is jsa' do
        # rubocop:disable Layout/LineLength
        let(:application_data) do
          super().deep_merge('client_details' => { 'applicant' => { 'benefit_type' => 'jsa', 'last_jsa_appointment_date' => 'Fri, 12 Jan 2024' } })
        end
        # rubocop:enable Layout/LineLength

        it 'shows the last jsa appointment date' do
          expect(page).to have_content("Passporting Benefit Income-based Jobseeker's Allowance (JSA)")
          expect(page).to have_content('Date of latest JSA appointment 12/01/2024')
        end
      end

      context 'when it was not asked at time of application' do
        let(:application_data) do
          super().deep_merge('client_details' => { 'applicant' => { 'benefit_type' => nil } })
        end

        it 'shows `Not asked`' do
          expect(page).to have_content('Passporting Benefit Not asked when this application was submitted')
        end
      end
    end

    context 'when the applicant is under 18' do
      let(:application_data) { super().merge('means_passport' => ['on_age_under18']) }

      it 'does not show the passporting benefit row' do
        expect(page).to have_no_content('Passporting Benefit')
      end
    end
  end

  context 'when date stamp is earlier than date received' do
    let(:application_data) { super().deep_merge('date_stamp' => '2022-11-21T16:57:51.000+00:00') }

    it 'includes the correct date stamp' do
      expect(page).to have_content('Date stamp 21/11/2022')
    end
  end

  it 'includes the applicant details' do
    expect(page).to have_content('AJ123456C')
  end

  describe 'the overaall offence class' do
    context 'when at least one of the offences is manually input' do
      it 'displays undetermined overall offence class badge' do
        expect(page).to have_content('Overall offence class Undetermined')
      end
    end

    context 'with offence class provided' do
      let(:application_data) do
        super().deep_merge('case_details' => { 'offence_class' => 'C' })
      end

      it 'displays calculated overall offence class badgee' do
        expect(page).to have_content('Overall offence class Class C')
      end
    end
  end

  it 'does not show the CTAs' do
    expect(page).to have_no_content('Mark as completed')
  end

  context 'with optional fields not provided' do
    let(:application_data) do
      super().deep_merge('client_details' => { 'applicant' => { 'home_address' => nil, 'telephone_number' => nil } })
    end

    it 'shows that the URN was not provided' do
      expect(page).to have_content('Unique reference number (URN) Not provided')
    end

    it 'shows that other names were not provided' do
      expect(page).to have_content('Other names Not provided')
    end

    it 'shows that the client telephone number was not provided' do
      expect(page).to have_content('UK Telephone number Not provided')
    end

    it 'shows that the client home address was not provided' do
      expect(page).to have_content('Home address Does not have a home address')
    end
  end

  describe 'court hearing' do
    let(:application_data) do
      super().deep_merge('case_details' => hearing_details)
    end

    let(:first_court_hearing) do
      first(:xpath, "//div[@class='govuk-summary-list__row'][contains(dt, 'First court hearing the case')]")
    end

    let(:next_court_hearing) do
      first(:xpath, "//div[@class='govuk-summary-list__row'][contains(dt, 'Next court hearing the case')]")
    end

    context 'when first court hearing' do
      let(:hearing_details) do
        {
          'hearing_court_name' => 'Westminster Magistrates Court',
          'first_court_hearing_name' => 'Westminster Magistrates Court',
          'is_first_court_hearing' => 'yes',
        }
      end

      it 'shows same next and first court hearing the case' do
        expect(next_court_hearing).to have_content('Westminster Magistrates Court')
        expect(first_court_hearing).to have_content('Westminster Magistrates Court')
      end
    end

    context 'when the court has changed' do
      let(:hearing_details) do
        {
          'hearing_court_name' => 'Southwark Crown Court',
          'first_court_hearing_name' => 'Westminster Magistrates Court',
          'is_first_court_hearing' => 'no',
        }
      end

      it 'shows different next and first court hearing the case' do
        expect(next_court_hearing).to have_content('Southwark Crown Court')
        expect(first_court_hearing).to have_content('Westminster Magistrates Court')
      end
    end

    context 'when next and first court are the same' do
      let(:hearing_details) do
        {
          'hearing_court_name' => 'Westminster Magistrates Court',
          'first_court_hearing_name' => 'Westminster Magistrates Court',
          'is_first_court_hearing' => 'no',
        }
      end

      it 'shows both the next and first court hearing the case' do
        expect(next_court_hearing).to have_content('Westminster Magistrates Court')
        expect(first_court_hearing).to have_content('Westminster Magistrates Court')
      end
    end

    context 'when no court is hearing the case yet' do
      let(:hearing_details) do
        {
          'hearing_court_name' => 'Westminster Magistrates Court',
          'is_first_court_hearing' => 'no_hearing_yet',
        }
      end

      it 'shows next court hearing the case' do
        expect(next_court_hearing).to have_content('Westminster Magistrates Court')
      end

      it 'shows a `no hearing yet` message' do
        expect(first_court_hearing).to have_content('There has not been a hearing yet')
      end
    end

    context 'when the question about the first/next court was not asked' do
      let(:hearing_details) do
        {
          'hearing_court_name' => 'Westminster Magistrates Court',
          'is_first_court_hearing' => nil,
        }
      end

      it 'shows next court hearing the case' do
        expect(next_court_hearing).to have_content('Westminster Magistrates Court')
      end

      it 'shows a `not asked` message' do
        expect(first_court_hearing).to have_content('Not asked when this application was submitted')
      end
    end
  end

  describe 'displaying the residence type' do
    let(:residence_question) { 'Where the client usually lives' }
    let(:relationship_question) { 'Relationship to client' }

    context 'when the application has a residence type' do
      let(:application_data) do
        super().deep_merge('client_details' =>
                             { 'applicant' => { 'residence_type' => 'rented',
                                                'relationship_to_owner_of_usual_home_address' => nil } })
      end

      it 'shows the residence type' do
        expect(page).to have_summary_row(residence_question, 'In rented accommodation')
      end

      context 'when the residence type is someone else' do
        let(:application_data) do
          super().deep_merge('client_details' =>
                               { 'applicant' => { 'residence_type' => 'someone_else',
                                                  'relationship_to_owner_of_usual_home_address' => 'Friend' } })
        end

        it 'shows the relationship to client' do
          expect(page).to have_summary_row(residence_question, "In someone else's home")
          expect(page).to have_summary_row(relationship_question, 'Friend')
        end
      end

      context 'when it was not asked at time of application' do
        let(:application_data) do
          super().merge('client_details' => { 'applicant' => {} })
        end

        it 'does not display' do
          expect(page).to have_no_content(residence_question)
          expect(page).to have_no_content(relationship_question)
        end
      end
    end
  end
end

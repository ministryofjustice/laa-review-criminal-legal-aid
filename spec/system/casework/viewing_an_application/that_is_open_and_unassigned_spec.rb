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

  context 'when application_type is `change_in_financial_circumstances`' do
    context 'with reason provided' do
      let(:application_data) do
        super().deep_merge(
          'application_type' => 'change_in_financial_circumstances',
          'pre_cifc_reason' => 'Won the lottery'
        )
      end

      it 'displays reason' do
        expect(page).to have_content("Changes in client's financial circumstances")
        expect(page).to have_content('Won the lottery')
      end
    end

    context 'with USN provided' do
      let(:application_data) do
        super().deep_merge(
          'application_type' => 'change_in_financial_circumstances',
          'pre_cifc_reference_number' => 'pre_cifc_usn',
          'pre_cifc_usn' => 'usn_abc'
        )
      end

      it 'includes USN reference number' do
        expect(page).to have_content('USN of original application usn_abc')
      end
    end

    context 'with MAAT ID provided' do
      let(:application_data) do
        super().deep_merge(
          'application_type' => 'change_in_financial_circumstances',
          'pre_cifc_reference_number' => 'pre_cifc_maat_id',
          'pre_cifc_maat_id' => 'maat_id_abc'
        )
      end

      it 'includes MAAT ID reference number' do
        expect(page).to have_content('MAAT ID of original application maat_id_abc')
      end
    end
  end

  it 'shows that the application is unassigned' do
    expect(page).to have_content('Assigned to: no one')
  end

  it 'includes button to assign' do
    expect(page).to have_content('Assign to your list')
  end

  it 'includes the application type' do
    expect(page).to have_content('Initial application')
  end

  describe 'showing the means tested value' do
    subject(:means_tested_badge) do
      find('.govuk-summary-list__key',
           text: 'Subject to means test?')
        .sibling('.govuk-summary-list__value')
    end

    context 'when the application is subject to the means test' do
      it 'shows the blue passported badge' do
        expect(means_tested_badge).to have_content('Yes')
      end
    end

    context 'when the application is not subject to the means test' do
      let(:application_data) { super().merge('is_means_tested' => 'no') }

      it 'shows the red undetermined badge' do
        expect(means_tested_badge).to have_content('No')
      end
    end
  end

  describe 'showing the passporting benefit' do
    context 'when the application has a passporting benefit' do
      it 'shows the benefit type' do
        expect(page).to have_content('Passporting benefit Universal Credit')
      end

      context 'when the benefit type is jsa' do
        # rubocop:disable Layout/LineLength
        let(:application_data) do
          super().deep_merge('client_details' => { 'applicant' => { 'benefit_type' => 'jsa', 'last_jsa_appointment_date' => 'Fri, 12 Jan 2024' } })
        end
        # rubocop:enable Layout/LineLength

        it 'shows the last jsa appointment date' do
          expect(page).to have_content("Passporting benefit Income-based Jobseeker's Allowance (JSA)")
          expect(page).to have_content('Date of latest JSA appointment 12/01/2024')
        end
      end

      context 'when it was not asked at time of application' do
        let(:application_data) do
          super().deep_merge('client_details' => { 'applicant' => { 'benefit_type' => nil } })
        end

        it 'shows `Not asked`' do
          expect(page).to have_content('Passporting benefit Not asked when this application was submitted')
        end
      end
    end

    context 'when the applicant is under 18' do
      let(:application_data) { super().merge('means_passport' => ['on_age_under18']) }

      it 'does not show the passporting benefit row' do
        expect(page).to have_no_content('Passporting benefit')
      end

      describe 'client details card' do
        let(:card) do
          page.find('h2.govuk-summary-card__title', text: 'Client details').ancestor('div.govuk-summary-card')
        end

        it 'shows relevant details' do # rubocop:disable RSpec/MultipleExpectations
          within(card) do |card|
            expect(card).to have_summary_row 'First name', 'Kit'
            expect(card).to have_summary_row 'Last name', 'Pound'
            expect(card).to have_summary_row 'Other names', 'None'
            expect(card).to have_summary_row 'Date of birth', '09/06/2001'
          end
        end

        it 'does not display unanswered questions' do # rubocop:disable RSpec/MultipleExpectations
          expect(card).to have_no_content 'National Insurance Number'
          expect(card).to have_no_content 'Application registration card (ARC) number'
          expect(card).to have_no_content 'Partner'
          expect(card).to have_no_content 'Relationship status'
        end
      end
    end
  end

  context 'when date stamp is earlier than date received' do
    let(:application_data) { super().deep_merge('date_stamp' => '2022-11-21T16:57:51.000+00:00') }

    it 'includes the correct date stamp' do
      expect(page).to have_content('Date stamp 21/11/2022 4:57pm')
    end
  end

  describe 'displaying applicant details' do
    context 'when national insurance information is provided' do
      it 'displays the national insurance row' do
        expect(page).to have_content('National Insurance number AJ123456C')
      end
    end

    context 'when national insurance information is not provided' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'applicant' => { 'nino' => nil } })
      end

      it 'displays the national insurance row' do
        expect(page).to have_content('National Insurance number Not provided')
        expect(page).not_to have_content('Application registration card (ARC) number')
      end
    end

    context 'when arc information is provided' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'applicant' => { 'nino' => nil, 'arc' => 'ABC12/345678/A' } })
      end

      it 'displays the national insurance row' do
        expect(page).to have_content('National Insurance number Not provided')
        expect(page).to have_content('Application registration card (ARC) number ABC12/345678/A')
      end
    end
  end

  describe 'the overall offence class' do
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
      expect(page).to have_content('Unique reference number (URN) None')
    end

    it 'shows that other names were not provided' do
      expect(page).to have_content('Other names None')
    end

    it 'shows that the client telephone number was not provided' do
      expect(page).to have_content('Telephone number None')
    end

    it 'shows that the client home address was not provided' do
      expect(page).to have_content('Home address Does not have a home address')
    end
  end

  describe 'court hearing' do
    let(:application_data) do
      super().deep_merge('case_details' => hearing_details)
    end

    let(:first_court_hearing) { 'First court hearing' }
    let(:next_court_hearing) { 'Next court hearing' }
    let(:what_court) { 'What court is the hearing at' }

    context 'when first court hearing' do
      let(:hearing_details) do
        {
          'hearing_court_name' => 'Westminster Magistrates Court',
          'first_court_hearing_name' => 'Westminster Magistrates Court',
          'is_first_court_hearing' => 'yes',
        }
      end

      it 'shows same next and first court hearing the case' do
        within_card(next_court_hearing) do |card|
          expect(card).to have_summary_row(what_court, 'Westminster Magistrates Court')
        end
        within_card(first_court_hearing) do |card|
          expect(card).to have_summary_row(what_court, 'Westminster Magistrates Court')
        end
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
        within_card(next_court_hearing) do |card|
          expect(card).to have_summary_row(what_court, 'Southwark Crown Court')
        end
        within_card(first_court_hearing) do |card|
          expect(card).to have_summary_row(what_court, 'Westminster Magistrates Court')
        end
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
        within_card(next_court_hearing) do |card|
          expect(card).to have_summary_row(what_court, 'Westminster Magistrates Court')
        end
        within_card(first_court_hearing) do |card|
          expect(card).to have_summary_row(what_court, 'Westminster Magistrates Court')
        end
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
        within_card(next_court_hearing) do |card|
          expect(card).to have_summary_row(what_court, 'Westminster Magistrates Court')
        end
      end

      it 'shows a `no hearing yet` message' do
        within_card(next_court_hearing) do |card|
          expect(card).to have_summary_row('Same court as first hearing?', 'There has not been a hearing yet')
        end
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
        within_card(next_court_hearing) do |card|
          expect(card).to have_summary_row(what_court, 'Westminster Magistrates Court')
        end
      end

      it 'shows a `not asked` message' do
        within_card(first_court_hearing) do |card|
          expect(card).to have_summary_row(what_court, 'Not asked when this application was submitted')
        end
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
          within_card('Client contact details') do |card|
            expect(card).to have_summary_row(residence_question, "In someone else's home")
            expect(card).to have_summary_row(relationship_question, 'Friend')
          end
        end
      end

      context 'when it was not asked at time of application' do
        let(:application_data) do
          super().merge('client_details' => { 'applicant' => { 'date_of_birth' => '2000-11-11' } })
        end

        it 'does not display' do
          within_card('Client details') do |card|
            expect(card).to have_no_content(residence_question)
            expect(card).to have_no_content(relationship_question)
          end
        end
      end
    end
  end

  describe "displaying the client's relationship status details" do
    context 'when the question was asked' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'applicant' => { 'has_partner' => 'no',
                                                              'relationship_status' => 'separated',
                                                             'separation_date' => '2008-03-12' } })
      end

      it 'does display relationship status details' do
        within_card('Client details') do |card|
          expect(card).to have_content('Relationship status Separated')
          expect(card).to have_content('Date client separated from partner 12/03/2008')
        end
      end
    end

    context 'when the question was not asked' do
      it 'does not display relationship status details' do
        within_card('Client details') do |card|
          expect(card).to have_no_content('Relationship status')
          expect(card).to have_no_content('Date client separated from partner')
        end
      end
    end
  end
end

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
        expect(page).not_to have_content('Passporting Benefit')
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

  context 'with offence class' do
    context 'when at least one of the offences is manually input' do
      it 'does shows the class not determined badge' do
        table_body = find(:xpath,
                          "//table[@class='govuk-table app-dashboard-table govuk-!-margin-bottom-9']
                          //tr[contains(td[1], 'Non-listed offence, manually entered')]")

        expect(table_body).to have_content('Class not determined')
      end

      it 'displays undetermined overall offence class badge' do
        expect(page).to have_content('Overall offence class Undetermined')
      end
    end

    context 'with offence class provided' do
      let(:application_data) do
        super().deep_merge('case_details' => { 'offence_class' => 'C',
                                                'offences' => [{ 'name' => 'Robbery',
                                                                'offence_class' => 'C',
                                                                'slipstreamable' => true,
                                                                'dates' => [{
                                                                  'date_from' => '2020-12-12',
                                                                        'date_to' => nil
                                                                }] }] })
      end

      it 'does show the offence class' do
        row = first(:xpath,
                    "//table[@class='govuk-table app-dashboard-table govuk-!-margin-bottom-9']
                    //tr[contains(td[1], 'Robbery')]")

        expect(row).to have_content('Class C')
      end

      it 'displays calculated overall offence class badgee' do
        expect(page).to have_content('Overall offence class Class C')
      end
    end
  end

  context 'with correct codefendant information' do
    context 'when there is no codefendant' do
      let(:application_data) do
        super().deep_merge('case_details' => { 'codefendants' => [] })
      end

      it 'says there is no codefendant' do
        expect(page).to have_content('Co-defendants No')
      end
    end

    context 'when there is a codefendant' do
      context 'with a conflict' do
        it 'has no badge' do
          codefendant_row = find(:xpath,
                                 "//table[@class='govuk-table app-dashboard-table govuk-!-margin-bottom-9']
           //tr[contains(td[1], 'Conflict of interest')]")

          expect(codefendant_row).not_to have_content('No conflict')
        end
      end

      context 'with no conflict' do
        let(:application_data) do
          super().deep_merge('case_details' => { 'codefendants' => [{ 'first_name' => 'Billy',
                                                                  'last_name' => 'Bates',
                                                                  'conflict_of_interest' => 'no', }] })
        end

        let(:codefendant_row) do
          find(
            :xpath, "//table[@class='govuk-table app-dashboard-table govuk-!-margin-bottom-9']
           //tr[contains(td[1], 'Billy')]"
          )
        end

        it 'shows the No conflict badge' do
          within(codefendant_row) do
            badge = page.first('.govuk-tag.govuk-tag--red').text

            expect(badge).to have_content('No conflict')
          end
        end

        it 'shows the correct conflict caption text' do
          within(codefendant_row) do |row|
            expect(row.first('td')).to have_content('Billy Bates No conflict of interest')
          end
        end
      end
    end
  end

  context 'with ioj reasons' do
    context 'with ioj reason only' do
      it 'shows a table with ioj reason' do
        ioj_row = find(:xpath,
                       "//table[@class='govuk-table app-dashboard-table govuk-!-margin-bottom-9']
                        //tr[contains(td[1], 'Loss of liberty')]")

        expect(ioj_row).to have_content('More details about loss of liberty.')
      end
    end

    context 'with ioj passport and no ioj reason' do
      context 'with only an `on_offence` passport' do
        let(:application_data) do
          super().deep_merge(
            'ioj_passport' => ['on_offence'],
            'interests_of_justice' => nil
          )
        end

        it 'shows a summary list with the correct passport reason' do
          ioj_row = find(:xpath,
                         "//dl[@class='govuk-summary-list govuk-!-margin-bottom-9']
                              //div[contains(dt[1], 'Justification')]")

          expect(ioj_row).to have_content('Not needed based on offence')
        end
      end

      context 'with both ioj passports' do
        let(:application_data) do
          super().deep_merge(
            'ioj_passport' => %w[on_age_under18 on_offence],
            'interests_of_justice' => nil
          )
        end

        it 'shows a summary list with the correct passport reason' do
          ioj_row = find(:xpath,
                         "//dl[@class='govuk-summary-list govuk-!-margin-bottom-9']
                              //div[contains(dt[1], 'Justification')]")

          expect(ioj_row).to have_content('Not needed because the client is under 18 years old')
        end
      end
    end

    context 'when a passported application is a split case and resubmitted with ioj passport' do
      let(:application_data) do
        super().deep_merge('ioj_passport' => ['on_offence'])
      end

      it 'shows a table with ioj reason' do
        ioj_row = find(:xpath,
                       "//table[@class='govuk-table app-dashboard-table govuk-!-margin-bottom-9']
                        //tr[contains(td[1], 'Loss of liberty')]")

        expect(ioj_row).to have_content('More details about loss of liberty.')
      end
    end
  end

  it 'does not show the CTAs' do
    expect(page).not_to have_content('Mark as completed')
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

  context 'with supporting evidence' do
    it 'shows a table with supporting evidence' do
      evidence_row = find(:xpath,
                          "//table[@class='govuk-table app-dashboard-table govuk-!-margin-bottom-9']
                            //tr[contains(td[1], 'test.pdf')]")
      expect(evidence_row).to have_content('test.pdf Download file (pdf, 12 Bytes)')
    end
  end

  context 'with no supporting evidence' do
    let(:application_data) do
      super().deep_merge('supporting_evidence' => [])
    end

    it 'does not show supporting evidence section' do
      expect(page).not_to have_content('Supporting evidence')
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
    context 'when the application has a residence type' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'applicant' => { 'residence_type' => 'rented',
                                                                  'relationship_to_owner_of_usual_home_address' => nil } })
      end

      it 'shows the benefit type' do
        expect(page).to have_content('Where the client lives In rented accommodation')
      end

      context 'when the residence type is someone else' do
        let(:application_data) do
          super().deep_merge('client_details' => { 'applicant' => { 'residence_type' => 'someone_else',
                                                                    'relationship_to_owner_of_usual_home_address' => 'Friend' } })
        end

        it 'shows the relationship to client' do
          expect(page).to have_content("Where the client lives In someone else's home")
          expect(page).to have_content('Relationship to client Friend')
        end
      end

      context 'when it was not asked at time of application' do
        let(:application_data) do
          super().deep_merge('client_details' => { 'applicant' => { 'residence_type' => nil,
                                                                    'relationship_to_owner_of_usual_home_address' => nil } })
        end

        it 'does not display' do
          expect(page).not_to have_content('Where the client lives')
          expect(page).not_to have_content('Relationship to client Friend')
        end
      end
    end
  end
end

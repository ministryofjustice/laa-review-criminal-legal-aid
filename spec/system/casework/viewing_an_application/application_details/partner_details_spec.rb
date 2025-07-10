require 'rails_helper'

RSpec.describe 'When viewing partner details' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with partner details' do
    context 'when applicant does not have a partner' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'applicant' => { 'has_partner' => 'no' } })
      end

      it 'does not show the partner details section' do
        expect(page).to have_no_content('Partner details')
      end
    end

    context 'when the applicant has a partner' do
      it 'does show the partner details section' do
        expect(page).to have_content('Partner details')
      end

      it "displays the partner's relationship to the client" do
        expect(page).to have_content('Relationship to client Living together')
      end

      it "displays the partner's details" do
        expect(summary_card('Partner details')).to have_rows(
          'First name', 'Jennifer',
          'Last name', 'Holland',
          'Other names', 'Diane'
        )
      end

      it "displays the partner's date of birth" do
        expect(summary_card('Partner details')).to have_content('Date of birth 23/12/2001 Copy')
      end

      it "displays the partner's national insurance number" do
        expect(summary_card('Partner details')).to have_content('National Insurance number AB123456C Copy')
      end

      context 'when the partner has an arc number' do
        let(:application_data) do
          super().deep_merge('client_details' => {
                               'partner' => { 'nino' => nil, 'arc' => 'ABC12/345678/A', }
                             })
        end

        it "displays the partner's arc number" do
          expect(summary_card('Partner details')).to have_rows(
            'Application registration card (ARC) number', 'ABC12/345678/A'
          )
        end
      end

      it "displays the partner's case details" do
        expect(summary_card('Partner details')).to have_rows(
          'Partner involved in the case?', 'Co-defendant',
          'Conflict of interest?', 'No'
        )
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when partner is codefendant' do
        let(:application_data) do
          super().deep_merge('client_details' => {
                               'partner' => {
                                 'involvement_in_case' => 'codefendant', 'conflict_of_interest' => conflict_of_interest
                               }
                             })
        end

        context 'when yes' do
          let(:conflict_of_interest) { 'yes' }

          it "display the partner's conflict of interest details" do
            expect(summary_card('Partner details')).to have_rows(
              'Conflict of interest?', 'Yes'
            )
          end
        end

        context 'when no' do
          let(:conflict_of_interest) { 'no' }

          it "display the partner's conflict of interest details" do
            expect(summary_card('Partner details')).to have_rows(
              'Conflict of interest?', 'No'
            )
          end
        end
      end
      # rubocop:enable RSpec/NestedGroups

      context 'when partner is a victim' do
        let(:application_data) do
          super().deep_merge('client_details' => { 'partner' => { 'involvement_in_case' => 'victim' } })
        end

        it "does not display the partner's conflict of interest details" do
          within(summary_card('Partner details')) do |card|
            expect(card).to have_no_content('Conflict of interest?')
          end
        end
      end

      context 'when home address is present' do
        it "displays the partner's address details" do
          expect(summary_card('Partner details')).to have_rows(
            'Lives at same address as client?', 'No',
            'Home address', '53 Road Street Another nice city W1 2AA United Kingdom'
          )
        end
      end

      context 'when partner home address is missing' do
        let(:application_data) do
          super().deep_merge('client_details' => {
                               'partner' => {
                                 'has_same_address_as_client' => 'no',
                                 'home_address' => nil
                               }
                             })
        end

        it "displays the partner's address details" do
          expect(summary_card('Partner details')).to have_rows(
            'Lives at same address as client?', 'No'
          )
        end
      end

      context "when the partner's address details are not present" do
        let(:application_data) do
          super().deep_merge('client_details' =>
                               {
                                 'applicant' => {
                                   'residence_type' => 'none',
                                   'relationship_to_owner_of_usual_home_address' => nil
                                 },
                                   'partner' => { 'has_same_address_as_client' => nil,
                                   'home_address' => nil }
                               })
        end

        it "displays the partner's address details" do
          within summary_card('Partner details') do |card|
            expect(card).to have_no_content('Lives at same address as client?')
            expect(card).to have_no_content('Home address')
          end
        end
      end
    end
  end
end

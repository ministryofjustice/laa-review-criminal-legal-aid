require 'rails_helper'

RSpec.describe 'Viewing an apeal with no changes application' do
  include_context 'with stubbed application'

  let(:application_data) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(
      'case_details' => {
        'case_type' => Types::CaseType['appeal_to_crown_court'],
        'appeal_reference_number' => '123ABC',
        'appeal_usn' => appeal_usn,
        'appeal_maat_id' => appeal_maat_id,
        'appeal_lodged_date' => '2000-11-11',
        'appeal_original_app_submitted' => 'yes',
        'appeal_financial_circumstances_changed' => 'no'
      }
    )
  end

  before do
    visit crime_application_path(application_id)
  end

  describe 'case details card' do
    let(:card) do
      page.find('h2.govuk-summary-card__title', text: 'Case details').ancestor('div.govuk-summary-card')
    end

    context 'when appeal no changes with USN' do
      let(:appeal_maat_id) { nil }
      let(:appeal_usn) { '456DEF' }

      it 'shows savings details' do # rubocop:disable RSpec/MultipleExpectations
        within(card) do |card|
          expect(card).to have_summary_row 'Case type', 'Appeal to crown court'
          expect(card).to have_summary_row 'Changes to financial circumstances since original application?', 'No'
          expect(card).to have_summary_row 'Legal aid application for original case?', 'Yes'
          expect(card).to have_summary_row 'Original application USN', '456DEF'
        end
      end
    end

    context 'when appeal no changes with MAAT id' do
      let(:appeal_maat_id) { '456DEF' }
      let(:appeal_usn) { nil }

      it 'shows savings details' do # rubocop:disable RSpec/MultipleExpectations
        within(card) do |card|
          expect(card).to have_summary_row 'Case type', 'Appeal to crown court'
          expect(card).to have_summary_row 'Changes to financial circumstances since original application?', 'No'
          expect(card).to have_summary_row 'Legal aid application for original case?', 'Yes'
          expect(card).to have_summary_row 'Original application MAAT ID', '456DEF'
        end
      end
    end
  end
end

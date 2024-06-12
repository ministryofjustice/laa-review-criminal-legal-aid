require 'rails_helper'

RSpec.describe 'Viewing the other outgoings details of an application' do
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  include_context 'with stubbed application' do
    before do
      visit crime_application_path(application_id)
    end

    let(:outgoings_details) do
      { income_tax_rate_above_threshold:, partner_income_tax_rate_above_threshold:,
                                outgoings_more_than_income:, how_manage: }
    end

    let(:title_text) { 'Other outgoings' }
    let(:income_tax_rate_above_threshold) { nil }
    let(:partner_income_tax_rate_above_threshold) { nil }
    let(:outgoings_more_than_income) { nil }
    let(:how_manage) { 'Use savings' }

    context 'when there are no answers' do
      it { expect(page).to have_no_content(title_text) }
    end

    describe 'income tax threshold question' do
      let(:question) { 'In the last 2 years, has the client paid the 40% income tax rate?' }

      context 'when not answered' do
        let(:income_tax_rate_above_threshold) { nil }

        it { expect(page).to have_no_content(title_text) }
        it { expect(page).to have_no_content(question) }
      end

      context 'when yes' do
        let(:income_tax_rate_above_threshold) { 'yes' }

        it { expect(page).to have_content(title_text) }
        it { expect(page).to have_summary_row(question, 'Yes') }
      end

      context 'when no' do
        let(:income_tax_rate_above_threshold) { 'no' }

        it { expect(page).to have_content(title_text) }
        it { expect(page).to have_summary_row(question, 'No') }
      end
    end

    describe 'partner income tax threshold question' do
      let(:question) { 'In the last 2 years, has the partner paid the 40% income tax rate?' }
      let(:income_tax_rate_above_threshold) { 'yes' }

      context 'when not answered' do
        let(:partner_income_tax_rate_above_threshold) { nil }

        it { expect(page).to have_no_content(question) }
      end

      context 'when yes' do
        let(:partner_income_tax_rate_above_threshold) { 'yes' }

        it { expect(page).to have_summary_row(question, 'Yes') }
      end

      context 'when no' do
        let(:partner_income_tax_rate_above_threshold) { 'no' }

        it { expect(page).to have_summary_row(question, 'No') }
      end
    end

    describe 'outgoings more then income question' do
      let(:question) { 'Outgoings more than income?' }
      let(:how_manage_question) { 'How they cover outgoings that are more than their income?' }

      context 'when not answered' do
        let(:outgoings_more_than_income) { nil }

        it { expect(page).to have_no_content(title_text) }
        it { expect(page).to have_no_content(question) }
      end

      context 'when yes' do
        let(:outgoings_more_than_income) { 'yes' }

        it { expect(page).to have_content(title_text) }
        it { expect(page).to have_summary_row(question, 'Yes') }
        it { expect(page).to have_summary_row(how_manage_question, 'Use savings') }
      end

      context 'when no' do
        let(:outgoings_more_than_income) { 'no' }

        it { expect(page).to have_content(title_text) }
        it { expect(page).to have_summary_row(question, 'No') }
        it { expect(page).to have_no_content(how_manage_question) }
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end

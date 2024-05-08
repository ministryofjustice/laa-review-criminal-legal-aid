require 'rails_helper'

RSpec.describe 'Viewing the Interest of Justice / Justification for legal aid' do
  subject(:card) do
    page.find('h2.govuk-summary-card__title', text: 'Justification for legal aid')
        .ancestor('div.govuk-summary-card')
  end

  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'when justifications given' do
    it 'shows the justifications' do
      within(card) do |card|
        expect(card).to have_summary_row 'Loss of liberty', 'More details about loss of liberty.'
      end
    end
  end

  context 'when passported `on_offence`' do
    let(:application_data) do
      super().deep_merge(
        'ioj_passport' => ['on_offence'],
        'interests_of_justice' => nil
      )
    end

    it 'shows that none is needed based on offence' do
      within(card) do |card|
        expect(card).to have_summary_row 'Justification', 'Not needed based on offence'
      end
    end
  end

  context 'when passported on both offence and under 18' do
    let(:application_data) do
      super().deep_merge(
        'ioj_passport' => %w[on_age_under18 on_offence],
        'interests_of_justice' => nil
      )
    end

    it 'shows that none is needed based on age' do
      within(card) do |card|
        expect(card).to have_summary_row 'Justification', 'Not needed because the client is under 18 years old'
      end
    end
  end
end

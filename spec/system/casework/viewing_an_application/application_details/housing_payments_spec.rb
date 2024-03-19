require 'rails_helper'

RSpec.describe 'Viewing the housing payments of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with housing payments details' do
    it { expect(page).to have_content('Housing payments') }

    context 'when housing payment is mortgage' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'outgoings_details' => { 'outgoings' => outgoings } })
      end

      let(:outgoings) do
        [{ payment_type: 'mortgage', amount: 10_001, frequency: 'annual', metadata: {} }]
      end

      it 'shows mortgage details' do
        expect(page).to have_content('Which housing payment type? Mortgage')
        expect(page).to have_content('How much mortgage do they pay? £100.01 every year')
      end
    end

    context 'when housing payment is rent' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'outgoings_details' => { 'outgoings' => outgoings } })
      end

      let(:outgoings) do
        [{ payment_type: 'rent', amount: 99_999, frequency: 'four_weeks', metadata: {} }]
      end

      it 'shows rent details' do
        expect(page).to have_content('Which housing payment type? Rent')
        expect(page).to have_content('How much rent do they pay? £999.99 every 4 weeks')
      end
    end

    context 'when housing payment is board_and_lodging' do
      let(:application_data) do
        super().deep_merge('means_details' => { 'outgoings_details' => { 'outgoings' => outgoings } })
      end

      let(:outgoings) do
        [{
          payment_type: 'board_and_lodging',
          amount: 18_699,
          frequency: 'fortnight',
          metadata: {
            'payee_name' => 'John Snow',
            'payee_relationship_to_client' => 'Son',
            'board_amount' => 19_999,
            'food_amount' => 1_300,
          }
        }]
      end

      it 'shows board and lodgings details' do
        expect(page).to have_content('Which housing payment type? Board and lodgings')
        expect(page).to have_content('How much board and lodgings do they pay? £186.99 every 2 weeks')
      end

      it 'shows metadata' do
        [
          'How much does client pay for board and lodgings? £199.99 every 2 weeks',
          'What is the name of the person client pays for board and lodgings? John Snow',
          'What is client\'s relationship to this person? Son'
        ].each { |line| expect(page).to have_content(line) }
      end
    end

    context 'when council tax payment is provided' do
      let(:application_data) do
        super().deep_merge(
          'means_details' => {
            'pays_council_tax' => 'yes',
            'housing_payment_type' => 'rent',
            'outgoings_details' => { 'outgoings' => outgoings }
          }
        )
      end

      let(:outgoings) do
        [{ payment_type: 'council_tax', amount: 9_999, frequency: 'annual', metadata: {} }]
      end

      it 'shows council tax details' do
        expect(page).to have_content('Does client pay Council Tax where they usually live? Yes')
        expect(page).to have_content('How much council tax does client pay? £99.99 every year')
      end
    end
  end

  context 'with no housing payments details' do
    let(:application_data) do
      super().deep_merge(
        'means_details' => {
          'pays_council_tax' => 'yes',
          'housing_payment_type' => 'none',
          'outgoings_details' => { 'outgoings' => [] }
        }
      )
    end

    it 'shows housing payment details' do
      expect(page).to have_content('Which housing payment type? Client does not pay any payments')
    end

    it 'still shows council tax' do
      expect(page).to have_content('Does client pay Council Tax where they usually live? Yes')
    end
  end
end

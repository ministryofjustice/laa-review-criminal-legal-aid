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
        expect(page).to have_content('Type of payment Mortgage')
        expect(page).to have_content('Amount paid towards mortgage £100.01 every year')
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
        expect(page).to have_content('Type of payment Rent')
        expect(page).to have_content('Amount paid for rent, after taking away Housing Benefit £999.99 every 4 weeks')
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
        expect(page).to have_content('Type of payment Board and lodgings')
        expect(page).to have_content('Amount £199.99 every 2 weeks')
      end

      it 'shows metadata' do
        [
          'Amount paid for food £13.00 every 2 weeks',
          'Name of the person they pay John Snow',
          'Relationship to that person Son'
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
        expect(page).to have_content('Council Tax Yes')
        expect(page).to have_content('Council Tax amount yearly £99.99')
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
      expect(page).to have_content('Type of payment No')
    end

    it 'still shows council tax' do
      expect(page).to have_content('Council Tax Yes')
    end
  end
end

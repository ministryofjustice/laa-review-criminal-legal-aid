require 'rails_helper'

RSpec.describe 'Viewing the trust fund details of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with trust funds details' do
    it { expect(page).to have_content('Trust funds: client') }

    it 'shows whether client benefits from a trust fund' do
      expect(page).to have_content('Stands to benefit from a trust fund? Yes')
    end

    it 'shows the amount held in the fund and the yearly dividend' do
      expect(page).to have_content('Enter the amount held in the fund £1,000.00')
      expect(page).to have_content('Enter the yearly dividend £2,000.00')
    end
  end

  context 'when client does not benefit from a trust fund' do
    let(:application_data) do
      super().deep_merge('means_details' => { 'capital_details' => { 'will_benefit_from_trust_fund' => 'no',
                                                                     'trust_fund_amount_held' => nil,
                                                                     'trust_fund_yearly_dividend' => nil } })
    end

    it 'shows whether client benefits from a trust fund' do
      expect(page).to have_content('Stands to benefit from a trust fund? No')
    end

    it 'does not show amount held in the fund and the yearly dividend' do
      expect(page).to have_no_content('Enter the amount held in the fund £1,000.00')
      expect(page).to have_no_content('Enter the yearly dividend £2,000.00')
    end
  end

  context 'with no capital details' do
    let(:application_data) do
      super().deep_merge('means_details' => nil)
    end

    it 'does not show client trust fund section' do
      expect(page).to have_no_content('Trust funds: client')
    end
  end
end

require 'rails_helper'

RSpec.describe 'Viewing the income details of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with income details' do
    it 'shows income above threshold' do
      expect(page).to have_content('Income more than £12,475? No')
    end

    it 'shows has income savings assets' do
      expect(page).to have_content('Has income, savings or assets under a restraint or freezing order? No')
    end

    it 'shows land or property' do
      expect(page).to have_content('Has land or property? No')
    end

    it 'shows savings or investments' do
      expect(page).to have_content('Has savings or investments? Yes')
    end
  end

  context 'with no income details' do
    let(:application_data) do
      super().deep_merge('means_details' => nil)
    end

    it 'does not show income section' do
      expect(page).to have_no_content('Income')
    end
  end

  context 'with nil income details' do
    let(:application_data) do
      super().deep_merge('means_details' => { 'income_details' => { 'income_above_threshold' => 'yes',
                                                                    'has_frozen_income_or_assets' => nil,
                                                                    'client_owns_property' => nil,
                                                                    'has_savings' => nil, } })
    end

    it 'shows income above threshold' do
      expect(page).to have_content('Income more than £12,475? Yes')
    end

    it 'shows has income savings assets' do
      expect(page).to have_no_content('Has income, savings or assets under a restraint or freezing order?')
    end

    it 'shows land or property' do
      expect(page).to have_no_content('Has land or property?')
    end

    it 'shows savings or investments' do
      expect(page).to have_no_content('Has savings or investments?')
    end
  end
end

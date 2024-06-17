require 'rails_helper'

RSpec.describe 'Viewing the employment details of the partner' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with employment details' do
    it { expect(page).to have_content("Partner's employment") }

    it 'shows employment type' do
      expect(page).to have_content("Partner's employment status Not working")
    end
  end

  context 'with no income details' do
    let(:application_data) do
      super().deep_merge('means_details' => nil)
    end

    it 'does not show income section' do
      expect(page).to have_no_content("Partner's employment")
    end
  end
end

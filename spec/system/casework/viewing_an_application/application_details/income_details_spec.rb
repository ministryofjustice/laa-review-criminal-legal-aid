require 'rails_helper'

RSpec.describe 'Viewing the income details of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with income details' do
    context 'when partner is included in means' do
      let(:application_data) do
        super().deep_merge('client_details' => { 'partner' => { 'is_included_in_means_assessment' => true } })
      end

      it 'shows income above threshold' do
        expect(page).to have_content('Joint annual income more than £12,475 a year before tax? No')
      end
    end

    context 'when partner is not included in means' do
      it 'shows income above threshold' do
        expect(page).to have_content('Income more than £12,475 a year before tax? No')
      end
    end

    it 'shows has income savings assets' do
      expect(page).to have_content('Income, savings or assets under a restraint or freezing order No')
    end

    it 'shows land or property' do
      expect(page).to have_content('Client owns home, land or property? No')
    end

    it 'shows savings or investments' do
      expect(page).to have_content('Savings or investments? Yes')
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
    let(:income_details_attributes) do
      {
        'income_above_threshold' => 'yes',
        'has_frozen_income_or_assets' => nil,
        'client_owns_property' => nil,
        'has_savings' => nil
      }
    end

    let(:application_data) do
      super().deep_merge('means_details' => { 'income_details' => income_details_attributes })
    end

    it 'shows income above threshold' do
      expect(page).to have_content('Income more than £12,475 a year before tax? Yes')
    end

    it 'shows has income savings assets' do
      expect(page).to have_no_content('Income, savings or assets under a restraint or freezing order')
    end

    it 'shows land or property' do
      expect(page).to have_no_content('Has land or property?')
    end

    it 'shows savings or investments' do
      expect(page).to have_no_content('Has savings or investments?')
    end
  end

  context 'with `self assessment` and `work benefits` in income details' do
    let(:income_details_attributes) do
      {
        'applicant_other_work_benefit_received' => 'no',
        'applicant_self_assessment_tax_bill' => 'yes',
        'applicant_self_assessment_tax_bill_amount' => 555_00,
        'applicant_self_assessment_tax_bill_frequency' => 'fortnight'
      }
    end
    let(:application_data) do
      super().deep_merge('means_details' => { 'income_details' => income_details_attributes })
    end

    it 'shows Other work benefits' do
      expect(page).to have_content('Other work benefits? No')
    end

    it 'shows Self Assessment tax' do
      expect(page).to have_content('Self assessment tax calculation? Yes')
    end

    it 'shows Self Assessment tax amount with frequency' do
      expect(page).to have_content("Amount\n£555.00 every 2 weeks")
    end
  end
end

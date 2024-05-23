require 'rails_helper'

RSpec.describe IncomeBenefitsPresenter do
  subject(:benefits_presenter) { described_class.new(crime_application.means_details.income_details.income_benefits) }

  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:crime_application) { CrimeApplication.new(attributes) }
  let(:ownership_type) { 'applicant' }

  describe '#formatted_income_benefits' do
    subject(:formatted_income_benefits) { benefits_presenter.formatted_income_benefits(ownership_type) }

    it {
      expect(formatted_income_benefits).to include({ 'child' =>
                                                       be_a(LaaCrimeSchemas::Structs::IncomeDetails::IncomeBenefit),
                                              'incapacity' => nil,
                                              'industrial_injuries_disablement' => nil,
                                              'jsa' => nil,
                                              'other' => be_a(LaaCrimeSchemas::Structs::IncomeDetails::IncomeBenefit),
                                              'working_or_child_tax_credit' => nil })
    }

    # rubocop:disable Layout/LineLength
    context 'when presenting partner income benefits' do
      let(:ownership_type) { 'partner' }

      it {
        expect(formatted_income_benefits).to include({ 'child' => nil,
                                                     'incapacity' => nil,
                                                     'industrial_injuries_disablement' => nil,
                                                     'jsa' => nil,
                                                     'other' => nil,
                                                     'working_or_child_tax_credit' => be_a(LaaCrimeSchemas::Structs::IncomeDetails::IncomeBenefit) })
      }
    end
    # rubocop:enable Layout/LineLength

    context 'with empty income benefits' do
      before do
        attributes['means_details']['income_details']['income_benefits'] = []
      end

      it { expect(formatted_income_benefits).to eq({}) }
    end
  end
end

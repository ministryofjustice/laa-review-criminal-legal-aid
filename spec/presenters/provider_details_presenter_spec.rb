require 'rails_helper'

RSpec.describe ProviderDetailsPresenter do
  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:crime_application) { CrimeApplication.new(attributes) }
  let(:provider_details) { crime_application.provider_details }

  let(:office_details) do
    ProviderDataApi::OfficeDetails.new(
      'office' => {
        'addressLine1' => '102 Petty France',
        'addressLine2' => nil,
        'addressLine3' => nil,
        'addressLine4' => nil,
        'city' => 'London',
        'county' => nil,
        'postCode' => 'SW1H 9AJ'
      },
      'firm' => { 'firmName' => 'Mock Firm Ltd' }
    )
  end

  describe 'without office_details' do
    subject(:presenter) { described_class.present(provider_details) }

    it 'delegates schema fields to the underlying struct' do
      expect(presenter.office_code).to eq(provider_details.office_code)
      expect(presenter.legal_rep_first_name).to eq(provider_details.legal_rep_first_name)
    end

    describe '#firm_name' do
      it { expect(presenter.firm_name).to be_nil }
    end

    describe '#office_address' do
      it { expect(presenter.office_address).to be_nil }
    end
  end

  describe 'with office_details' do
    subject(:presenter) { described_class.new(provider_details, office_details:) }

    it 'still delegates schema fields to the underlying struct' do
      expect(presenter.office_code).to eq(provider_details.office_code)
    end

    describe '#firm_name' do
      it { expect(presenter.firm_name).to eq('Mock Firm Ltd') }
    end

    describe '#office_address' do
      subject(:office_address) { presenter.office_address }

      it { is_expected.to include('102 Petty France') }
      it { is_expected.to include('London') }
      it { is_expected.to include('SW1H 9AJ') }

      it 'separates parts with <br> tags' do
        expect(office_address).to include('<br>')
      end

      context 'when optional lines are present' do
        let(:office_details) do
          ProviderDataApi::OfficeDetails.new(
            'office' => {
              'addressLine1' => 'Floor 1',
              'addressLine2' => '102 Petty France',
              'addressLine3' => 'Westminster',
              'addressLine4' => nil,
              'city' => 'London',
              'county' => 'Greater London',
              'postCode' => 'SW1H 9AJ'
            },
            'firm' => { 'firmName' => 'Mock Firm Ltd' }
          )
        end

        it { is_expected.to include('Floor 1') }
        it { is_expected.to include('Westminster') }
        it { is_expected.to include('Greater London') }
      end
    end
  end

  describe 'when office_details is unavailable' do
    subject(:presenter) { described_class.new(provider_details, office_details: :unavailable) }

    it 'delegates schema fields to the underlying struct' do
      expect(presenter.office_code).to eq(provider_details.office_code)
      expect(presenter.legal_rep_first_name).to eq(provider_details.legal_rep_first_name)
    end

    describe '#firm_name' do
      it { expect(presenter.firm_name).to eq('Firm name temporarily unavailable') }
    end

    describe '#office_address' do
      it { expect(presenter.office_address).to eq('Address temporarily unavailable') }
    end
  end

  describe 'when office_details is not found' do
    subject(:presenter) { described_class.new(provider_details, office_details: :not_found) }

    it 'delegates schema fields to the underlying struct' do
      expect(presenter.office_code).to eq(provider_details.office_code)
      expect(presenter.legal_rep_first_name).to eq(provider_details.legal_rep_first_name)
    end

    describe '#firm_name' do
      it { expect(presenter.firm_name).to eq('Firm name unavailable') }
    end

    describe '#office_address' do
      it { expect(presenter.office_address).to eq('Address unavailable') }
    end
  end
end

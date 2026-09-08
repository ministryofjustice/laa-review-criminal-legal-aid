require 'rails_helper'

RSpec.describe ProviderDataApi::GetOfficeDetails do
  subject(:get_office_details) { described_class.new(office_code: office_code, http_client: http_client.call) }

  let(:office_code) { '1A234B' }
  let(:http_client) { instance_double(ProviderDataApi::HttpClient, call: connection) }
  let(:connection) { instance_double(Faraday::Connection) }
  let(:response) { instance_double(Faraday::Response, body:) }

  let(:body) do
    {
      'office' => {
        'addressLine1' => '102 Petty France',
        'addressLine2' => nil,
        'addressLine3' => nil,
        'addressLine4' => nil,
        'city' => 'London',
        'county' => nil,
        'postCode' => 'SW1H 9AJ'
      },
      'firm' => {
        'firmName' => 'Test Firm'
      }
    }
  end

  before do
    allow(connection).to receive(:get).and_return(response)
  end

  describe '#call' do
    subject(:result) { get_office_details.call }

    it 'makes a GET request to the offices endpoint' do
      result
      expect(connection).to have_received(:get).with(URI::Generic.build(path: '/provider-offices/1A234B'))
    end

    it { is_expected.to be_a ProviderDataApi::OfficeDetails }

    it 'parses the firm name' do
      expect(result.firm.firmName).to eq 'Test Firm'
    end

    it 'parses the office address' do # rubocop:disable RSpec/MultipleExpectations
      expect(result.office.addressLine1).to eq '102 Petty France'
      expect(result.office.city).to eq 'London'
      expect(result.office.postCode).to eq 'SW1H 9AJ'
    end

    context 'when the API returns a 404' do
      before do
        allow(connection).to receive(:get).and_raise(Faraday::ResourceNotFound)
      end

      it 'raises ProviderDataApi::RecordNotFound' do
        expect { result }.to raise_error(ProviderDataApi::RecordNotFound)
      end
    end

    context 'when the API returns an invalid response' do
      let(:body) { { 'office' => {} } }

      it 'raises ProviderDataApi::InvalidResponse' do
        expect { result }.to raise_error(ProviderDataApi::InvalidResponse) do |error|
          expect(error.cause).to be_a Dry::Struct::Error
        end
      end
    end
  end

  describe '.call' do
    subject(:result) { described_class.call(office_code) }

    context 'when use_mock is false' do
      before do
        allow(Rails.configuration.x.provider_data_api).to receive(:use_mock).and_return('false')
        allow(ProviderDataApi::HttpClient).to receive(:call).and_return(connection)
      end

      it 'delegates to a new instance' do
        result
        expect(connection).to have_received(:get)
      end
    end

    context 'when use_mock is true' do
      before do
        allow(Rails.configuration.x.provider_data_api).to receive(:use_mock).and_return('true')
      end

      it { is_expected.to be_a ProviderDataApi::OfficeDetails }

      it 'does not make an HTTP request' do
        result
        expect(connection).not_to have_received(:get)
      end
    end
  end
end

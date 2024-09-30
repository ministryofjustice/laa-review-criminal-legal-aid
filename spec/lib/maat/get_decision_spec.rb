require 'rails_helper'

RSpec.describe Maat::GetDecision do
  subject(:get_decision) { described_class.new(http_client: http_client.call) }

  let(:http_client) { instance_double(Maat::HttpClient, call: connection) }
  let(:response) { instance_double(Faraday::Response, body:) }
  let(:connection) { instance_double(Faraday::Connection) }
  let(:usn) { 123_456 }
  let(:maat_id) { '123456B' }

  let(:body) { { funding_decision: 'GRANTED' } }

  before do
    allow(connection).to receive(:get) { response }
    allow(Maat::Decision).to receive(:build).with(body)
  end

  describe '#by_usn' do
    before do
      get_decision.by_usn(usn)
    end

    it 'makes a GET request to the MAAT API USN path' do
      expect(connection).to have_received(:get)
        .with('/api/external/v1/crime-application/result/usn/123456')

      expect(Maat::Decision).to have_received(:build).with(body)
    end

    context 'when decision is empty found' do
      let(:body) { {} }

      it 'builds a Maat::Decision from the results' do
        expect(Maat::Decision).not_to have_received(:build)
      end
    end
  end

  describe '#by_maat_id' do
    before { get_decision.by_maat_id(maat_id) }

    it 'makes a GET request to the MAAT API ID path' do
      expect(connection).to have_received(:get)
        .with('/api/external/v1/crime-application/result/rep-order-id/123456B')

      expect(Maat::Decision).to have_received(:build).with(body)
    end
  end
end

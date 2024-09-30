require 'rails_helper'

RSpec.describe Maat::GetDecision do
  subject(:get_decision) { described_class.new(http_client: http_client.call) }

  let(:http_client) { instance_double(Maat::HttpClient, call: connection) }
  let(:response) { instance_double(Faraday::Response, body:) }
  let(:connection) { instance_double(Faraday::Connection) }
  let(:usn) { 123_456 }
  let(:maat_id) { 60_123 }

  let(:body) { { 'maat_ref' => 60_123, 'funding_decision' => 'GRANTED' } }

  before do
    allow(connection).to receive(:get) { response }
    allow(Maat::Decision).to receive(:build).with(body) { instance_double(Maat::Decision) }
  end

  describe '#by_usn' do
    before { get_decision.by_usn(usn) }

    it 'makes a GET request to the MAAT API USN path' do
      expect(connection).to have_received(:get)
        .with('/api/external/v1/crime-application/result/usn/123456')

      expect(Maat::Decision).to have_received(:build).with(body)
    end

    context 'when decision is empty found' do
      let(:body) { {} }

      it 'returns nil' do
        expect(Maat::Decision).not_to have_received(:build)
      end
    end

    context 'when decision found has no maat id' do
      let(:body) { { 'maat_ref' => nil } }

      it 'returns nil' do
        expect(Maat::Decision).not_to have_received(:build)
      end
    end
  end

  describe '#by_usn!' do
    subject(:get_by_usn!) { get_decision.by_usn!(usn) }

    it 'makes a GET request to the MAAT API USN path' do
      get_by_usn!

      expect(Maat::Decision).to have_received(:build).with(body)
    end

    context 'when decision is empty found' do
      let(:body) { {} }

      it 'raises Maat::RecordNotFound' do
        expect { get_by_usn! }.to raise_error(Maat::RecordNotFound)
      end
    end

    context 'when decision found has no maat id' do
      let(:body) { { 'maat_ref' => nil } }

      it 'raises Maat::RecordNotFound' do
        expect { get_by_usn! }.to raise_error(Maat::RecordNotFound)
      end
    end
  end

  describe '#by_maat_id' do
    before { get_decision.by_maat_id(maat_id) }

    it 'makes a GET request to the MAAT API ID path' do
      expect(connection).to have_received(:get)
        .with('/api/external/v1/crime-application/result/rep-order-id/60123')

      expect(Maat::Decision).to have_received(:build).with(body)
    end
  end
end

require 'rails_helper'

RSpec.describe ApiClient do
  subject(:client) do
    stubbed_connection = Faraday.new { |b| b.adapter(:test, adapter) }

    described_class.new(connection: stubbed_connection)
  end

  let(:adapter) { Faraday::Adapter::Test::Stubs.new }

  let(:api_response) do
    [
      status,
      { 'Content-Type': 'application/javascript' },
      body
    ]
  end

  after do
    adapter.verify_stubbed_calls
  end

  describe '.all' do
    subject(:all) { client.all }

    let(:status) { 200 }
    let(:body) { file_fixture('crime_apply_data/applications.json').read }

    before do
      adapter.get('/applications') { api_response }
    end

    it 'returns a list of applications from the dev api' do
      expect(all.first['application_reference']).to eq('LAA-696dd4')
    end

    context 'when the api returns an empty list' do
      let(:body) { [].to_json }

      it 'returns an empty array' do
        expect(all).to eq([])
      end
    end

    context 'when the api returns a Not Found Error' do
      let(:status) { 404 }

      it 'returns an empty array' do
        expect(all).to eq([])
      end
    end

    context 'when the api returns a Server Error' do
      let(:status) { 500 }

      it 'returns an empty array' do
        expect(all).to eq([])
      end
    end
  end

  describe '.find(:id)' do
    subject(:find) { client.find(id) }

    let(:id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

    let(:body) do
      file_fixture("crime_apply_data/applications/#{id}.json").read
    end

    let(:status) { 200 }

    before do
      adapter.get("/applications/#{id}") { api_response }
    end

    it 'returns the application as a hash' do
      expect(find['application_reference']).to eq('LAA-696dd4')
    end

    context 'when the application does not exist' do
      let(:status) { 404 }

      it 'returns the application as a hash' do
        expect(find).to be_nil
      end
    end

    context 'when there is a server error' do
      let(:status) { 500 }

      it 'returns the application as a hash' do
        expect(find).to be_nil
      end
    end
  end
end

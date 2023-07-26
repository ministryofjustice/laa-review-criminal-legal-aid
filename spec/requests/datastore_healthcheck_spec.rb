require 'rails_helper'

RSpec.describe 'Datastore healthcheck endpoints' do
  describe 'Health endpoint' do
    context 'when success' do
      before do
        stub_request(:get, 'https://datastore-api-stub.test/health')
          .to_return(body: '{}')
      end

      it 'reports success' do
        get '/datastore/health'
        expect(response.body).to eq('{}')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when failure' do
      before do
        stub_request(:get, 'https://datastore-api-stub.test/health')
          .to_raise(StandardError)
      end

      it 'reports failure' do
        get '/datastore/health'
        expect(response.body).to eq('{"error":"Exception from WebMock"}')
        expect(response).to have_http_status(:service_unavailable)
      end
    end
  end

  describe 'Ping endpoint' do
    context 'when success' do
      before do
        stub_request(:get, 'https://datastore-api-stub.test/ping')
          .to_return(body: '{}')
      end

      it 'reports success' do
        get '/datastore/ping'
        expect(response.body).to eq('{}')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when failure' do
      before do
        stub_request(:get, 'https://datastore-api-stub.test/ping')
          .to_raise(StandardError)
      end

      it 'reports failure' do
        get '/datastore/ping'
        expect(response.body).to eq('{"error":"Exception from WebMock"}')
        expect(response).to have_http_status(:service_unavailable)
      end
    end
  end
end

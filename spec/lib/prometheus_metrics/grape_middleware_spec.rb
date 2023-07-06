require 'rails_helper'

describe PrometheusMetrics::GrapeMiddleware do
  describe '#custom_labels' do
    subject(:grape_middleware) { described_class.new(nil, { instrument: nil }).custom_labels(env) }

    context 'when it is an API request' do
      let(:env) do
        {
          'api.endpoint' => api_endpoint,
          'api.version' => api_version,
        }
      end

      # rubocop:disable RSpec/VerifiedDoubles
      let(:api_endpoint) do
        double('api.endpoint', namespace: '/applications', options: { method: ['GET'] })
      end
      # rubocop:enable RSpec/VerifiedDoubles

      context 'when there is no version' do
        let(:api_version) { nil }

        it { expect(grape_middleware).to eq({ api_method: 'GET', api_namespace: '/applications', api_version: 'n/a' }) }
      end

      context 'when there is version' do
        let(:api_version) { 'v1' }

        it { expect(grape_middleware).to eq({ api_method: 'GET', api_namespace: '/applications', api_version: 'v1' }) }
      end
    end

    context 'when it is not an API request' do
      let(:env) { { 'api.endpoint' => nil } }

      it { expect(grape_middleware).to be_nil }
    end

    context 'when something blows up' do
      let(:env) { { 'api.endpoint' => { foo: :bar } } }

      it { expect(grape_middleware).to be_nil }
    end
  end
end

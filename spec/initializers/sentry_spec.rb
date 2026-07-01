require 'rails_helper'

RSpec.describe 'Sentry before_send callback' do # rubocop:disable RSpec/DescribeClass
  subject(:result) { Sentry.configuration.before_send.call(event, {}) }

  let(:event) do
    Sentry::ErrorEvent.new(configuration: Sentry.configuration).tap do |e|
      e.user = { 'email' => 'user@example.com', 'first_name' => 'John', 'id' => 'safe-id' }
    end
  end

  def build_request_interface
    Sentry::RequestInterface.new(
      env: Rack::MockRequest.env_for('/test'),
      send_default_pii: false,
      rack_env_whitelist: Sentry.configuration.rack_env_whitelist
    )
  end

  it 'returns a Sentry::ErrorEvent' do
    expect(result).to be_a(Sentry::ErrorEvent)
  end

  describe 'user field filtering' do
    it 'filters sensitive user fields' do
      expect(result.user['email']).to eq('[FILTERED]')
      expect(result.user['first_name']).to eq('[FILTERED]')
    end

    it 'preserves non-sensitive user fields' do
      expect(result.user['id']).to eq('safe-id')
    end
  end

  describe 'request data filtering' do
    let(:request_interface) do
      build_request_interface.tap do |r|
        r.data    = { 'nino' => 'AB123456C', 'action' => 'submit' }
        r.cookies = { 'token' => 'abc123', '_ga' => 'safe-ga-value' }
      end
    end

    before { allow(event).to receive(:request).and_return(request_interface) }

    it 'filters sensitive fields in request data' do
      expect(result.request.data['nino']).to eq('[FILTERED]')
    end

    it 'preserves non-sensitive fields in request data' do
      expect(result.request.data['action']).to eq('submit')
    end

    it 'filters sensitive fields in cookies' do
      expect(result.request.cookies['token']).to eq('[FILTERED]')
    end

    it 'preserves non-sensitive cookie values' do
      expect(result.request.cookies['_ga']).to eq('safe-ga-value')
    end
  end

  describe 'query string filtering' do
    let(:request_interface) do
      build_request_interface.tap do |r|
        r.query_string = 'search_text=sensitive+name&page=2'
      end
    end

    before { allow(event).to receive(:request).and_return(request_interface) }

    it 'filters sensitive query string parameters' do
      parsed = Rack::Utils.parse_nested_query(result.request.query_string)
      expect(parsed['search_text']).to eq('[FILTERED]')
    end

    it 'preserves non-sensitive query string parameters' do
      parsed = Rack::Utils.parse_nested_query(result.request.query_string)
      expect(parsed['page']).to eq('2')
    end

    context 'when query_string is blank' do
      before { request_interface.query_string = '' }

      it 'does not modify query_string' do
        expect(result.request.query_string).to eq('')
      end
    end
  end

  context 'when event.request is nil' do
    before { allow(event).to receive(:request).and_return(nil) }

    it 'returns the event without error' do
      expect(result).to be_a(Sentry::ErrorEvent)
    end
  end

  context 'when event.user is blank' do
    let(:event) { Sentry::ErrorEvent.new(configuration: Sentry.configuration) }

    it 'returns the event without error' do
      expect(result).to be_a(Sentry::ErrorEvent)
    end

    it 'leaves user as blank' do
      expect(result.user).to eq({})
    end
  end

  context 'when request.data is nil' do
    let(:request_interface) do
      build_request_interface.tap do |r|
        r.data    = nil
        r.cookies = { 'token' => 'abc123' }
      end
    end

    before { allow(event).to receive(:request).and_return(request_interface) }

    it 'returns the event without error' do
      expect(result).to be_a(Sentry::ErrorEvent)
    end

    it 'leaves data as nil' do
      expect(result.request.data).to be_nil
    end
  end

  context 'when request.cookies is nil' do
    let(:request_interface) do
      build_request_interface.tap do |r|
        r.data    = { 'action' => 'submit' }
        r.cookies = nil
      end
    end

    before { allow(event).to receive(:request).and_return(request_interface) }

    it 'returns the event without error' do
      expect(result).to be_a(Sentry::ErrorEvent)
    end

    it 'leaves cookies as nil' do
      expect(result.request.cookies).to be_nil
    end
  end
end

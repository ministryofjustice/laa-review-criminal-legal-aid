require 'rails_helper'

RSpec.describe 'Requesting applications' do
  subject(:applications_response) { response }

  before do
    stub_request(:get, "#{ENV.fetch('CRIME_APPLY_API_URL')}applications")
      .to_return(body: stubbed_body, status: stubbed_status)

    get '/applications'
  end

  context 'when the crime apply api returns applications' do
    let(:stubbed_body) { file_fixture('crime_apply_data/applications.json').read }
    let(:stubbed_status) { 200 }

    it { is_expected.to be_successful }
  end

  context 'when the crime apply api returns no applications' do
    let(:stubbed_body) { [].to_json }
    let(:stubbed_status) { 200 }

    it { is_expected.to be_successful }
  end

  context 'with a crime apply api server error' do
    let(:stubbed_body) { 'Server Error' }
    let(:stubbed_status) { 500 }

    it { is_expected.to be_successful }
  end

  context 'with a crime apply api not found error' do
    let(:stubbed_body) { 'Not Found' }
    let(:stubbed_status) { 404 }

    it { is_expected.to be_successful }
  end
end

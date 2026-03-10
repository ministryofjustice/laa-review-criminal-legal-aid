require 'rails_helper'

RSpec.describe 'Viewing all evidence' do
  include Devise::Test::IntegrationHelpers

  include_context 'with an existing user'
  include_context 'with stubbed application'

  before do
    sign_in user
    allow(FeatureFlags).to receive(:view_all_evidence) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }
  end

  describe 'GET /documents/all' do
    subject(:get_all) do
      get "/documents/all?crime_application_id=#{application_id}"
    end

    it 'returns a successful response' do
      get_all
      expect(response).to have_http_status(:ok)
    end

    it 'displays the page heading' do
      get_all
      expect(response.body).to include('All evidence')
    end

    it 'displays the filename for each document' do
      get_all
      expect(response.body).to include('test.pdf')
    end

    it 'embeds the viewable document using the embed documents path' do
      get_all
      expect(response.body).to include(
        CGI.escapeHTML(embed_documents_path(crime_application_id: application_id, id: '123/abcdef1234'))
      )
    end
  end
end

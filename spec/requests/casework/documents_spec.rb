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

  describe 'GET /applications/:crime_application_id/documents' do
    subject(:get_all) do
      get "/applications/#{application_id}/documents"
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

    it 'embeds the viewable document using the raw documents path' do
      get_all
      expect(response.body).to include(
        CGI.escapeHTML(raw_crime_application_document_path(application_id, '123/abcdef1234'))
      )
    end
  end
end

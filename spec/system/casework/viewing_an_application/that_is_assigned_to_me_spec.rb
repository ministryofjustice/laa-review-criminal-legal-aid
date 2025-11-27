require 'rails_helper'

RSpec.describe 'Viewing an application that is assigned to me' do
  include_context 'when downloading a document'

  let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  before do
    allow(FeatureFlags).to receive(:view_evidence) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: false)
    }

    visit '/'
    visit crime_application_path(application_id)
    click_button 'Assign to your list'
  end

  it 'includes the name of the assigned user' do
    expect(page).to have_content('Assigned to: Joe EXAMPLE')
  end

  it 'includes button to unassign' do
    expect(page).to have_content('Remove from your list')
  end

  it 'displays mark as ready for MAAT button as default' do
    expect(page).to have_content('Mark as ready for MAAT')
  end

  describe 'Evidence download' do
    context 'when a user attempts to download supporting evidence' do
      it 'raises error if document is not part of current application' do
        visit download_documents_path(crime_application_id: application_id, id: '321/hijklm5678')
        expect(page).to have_content('File must be uploaded to current application to download')
      end

      it 'successfully downloads if document is part of current application' do
        # as there is no visual change on the page, we assert the expect redirect occurred
        click_on 'Download file (pdf, 12 Bytes)'
        expect(page).to have_current_path(presign_download_url)
      end
    end

    context 'when there is an error with obtaining the download url' do
      let(:expected_return) { { status: 500 } }

      it 'displays a message if there is an error obtaining the url' do
        click_on 'Download file (pdf, 12 Bytes)'
        expect(page).to have_content('test.pdf could not be downloaded – try again')
      end
    end
  end
end

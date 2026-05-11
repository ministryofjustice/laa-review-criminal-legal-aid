require 'rails_helper'

RSpec.describe 'Viewing all evidence' do
  include_context 'with stubbed application'

  # Override application_data in a nested context so super() can reach
  # the shared context's let definition through the example group hierarchy.
  context 'with a mix of file types' do
    let(:pdf_s3_key) { '123/abcdef1234' }
    let(:image_s3_key) { '123/image1234' }
    let(:docx_s3_key) { '123/docx1234' }

    let(:application_data) do
      super().deep_merge(
        'supporting_evidence' => [
          {
            's3_object_key' => pdf_s3_key,
            'filename' => 'test.pdf',
            'content_type' => 'application/pdf',
            'file_size' => 12,
            'scan_at' => '2023-10-01 12:34:56'
          },
          {
            's3_object_key' => image_s3_key,
            'filename' => 'photo.jpg',
            'content_type' => 'image/jpeg',
            'file_size' => 2048,
            'scan_at' => '2023-10-01 12:34:56'
          },
          {
            's3_object_key' => docx_s3_key,
            'filename' => 'report.docx',
            'content_type' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'file_size' => 1024,
            'scan_at' => '2023-10-01 12:34:56'
          }
        ]
      )
    end

    before do
      stub_request(:put, 'https://datastore-api-stub.test/api/v1/documents/presign_download')
        .to_return_json(
          status: 201,
          body: { url: 'https://localhost.localstack.cloud:4566/crime-apply-documents-dev/42/presigned' }
        )

      stub_request(:get, /localhost\.localstack\.cloud.*crime-apply-documents/)
        .to_return(status: 200, body: 'file content', headers: { 'Content-Type' => 'application/octet-stream' })

      allow(EvidenceAccessLogger).to receive(:log_view)
      visit crime_application_documents_path(application_id)
    end

    it 'displays the page heading' do
      expect(page).to have_content('All evidence')
    end

    it 'displays the filename for each viewable document' do
      expect(page).to have_content('test.pdf')
      expect(page).to have_content('photo.jpg')
    end

    it 'does not display non-viewable files in the accordion' do
      expect(page).to have_no_content('report.docx')
    end

    it 'embeds the PDF in an iframe' do
      expect(page).to have_css(
        "iframe[src='#{raw_crime_application_document_path(application_id, pdf_s3_key)}']"
      )
    end

    it 'embeds the image using an img tag' do
      expect(page).to have_css(
        "img[src='#{raw_crime_application_document_path(application_id, image_s3_key)}']"
      )
    end

    it 'displays a "View in a new tab" link for PDF' do
      expect(page).to have_link('View in a new tab',
                                href: crime_application_document_path(application_id, pdf_s3_key))
    end

    it 'displays a "View in a new tab" link for images' do
      expect(page).to have_link('View in a new tab',
                                href: crime_application_document_path(application_id, image_s3_key))
    end

    it 'displays rotate or zoom instructions for images' do
      expect(page).to have_content('Rotate or zoom')
      expect(page).to have_content('Hover over the image and press Ctrl twice')
    end

    context 'when the page loads' do
      before do
        driven_by(:headless_chrome)

        visit '/'
        click_button 'Start now'
        select current_user.email
        click_button 'Sign in'

        allow(EvidenceAccessLogger).to receive(:log_view)
        visit crime_application_documents_path(application_id)
      end

      it 'logs a view event for each embedded document' do # rubocop:disable RSpec/MultipleExpectations
        expect(page).to have_css(
          "iframe[src='#{raw_crime_application_document_path(application_id, pdf_s3_key)}']"
        )
        expect(page).to have_css(
          "img[src='#{raw_crime_application_document_path(application_id, image_s3_key)}']"
        )
        expect(EvidenceAccessLogger).to have_received(:log_view).twice
      end
    end
  end
end

require 'rails_helper'

RSpec.describe SupportingEvidenceComponent, type: :component do
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:supporting_evidence) { [] }

  before do
    allow(crime_application).to receive_messages(id: '12345', supporting_evidence: supporting_evidence)
    render_inline(described_class.new(crime_application:))
  end

  it 'displays "Files" as the summary card title' do
    expect(page.first('h2.govuk-summary-card__title').text).to eq('Files')
  end

  context 'when there are no files uploaded' do
    let(:supporting_evidence) { [] }

    it 'displays no files message' do
      expect(page).to have_text('No files were uploaded')
    end

    it 'does not display any links' do
      expect(page).not_to have_link
    end
  end

  context 'when there are files uploaded' do
    let(:pdf_evidence) do
      Document.new(
        filename: 'document1.pdf',
        content_type: 'application/pdf',
        file_extension: 'pdf',
        file_size: 1024,
        s3_object_key: 'key1'
      )
    end

    let(:csv_evidence) do
      Document.new(
        filename: 'document2.csv',
        content_type: 'application/octet-stream',
        file_extension: 'csv',
        file_size: 2048,
        s3_object_key: 'key2'
      )
    end

    let(:supporting_evidence) { [pdf_evidence, csv_evidence] }

    let(:viewable_row) do
      page.find('dt', text: 'document1.pdf').ancestor('.govuk-summary-list__row')
    end

    let(:non_viewable_row) do
      page.find('dt', text: 'document2.csv').ancestor('.govuk-summary-list__row')
    end

    context 'when view_evidence feature flag is enabled' do
      before do
        allow(FeatureFlags).to receive(:view_evidence) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
        render_inline(described_class.new(crime_application:))
      end

      describe 'view evidence link for viewable documents' do
        subject(:view_link) { viewable_row.find(:link, 'View') }

        it 'links to the document viewer endpoint and opens in a new tab' do
          expect(view_link[:href]).to eq '/documents?crime_application_id=12345&id=key1'
          expect(view_link[:target]).to eq '_blank'
        end

        it 'applies GOV.UK summary list action styling' do
          expect(view_link[:class]).to match 'govuk-summary-list__actions-list-item'
        end

        it 'displays with bold font weight to emphasize the primary action' do
          expect(view_link[:class]).to match 'govuk-!-font-weight-bold'
        end

        it 'includes the filename as visually hidden text for screen readers' do
          expect(view_link[:visually_hidden_text]).to match 'document1.pdf'
        end
      end

      describe 'download evidence link' do
        subject(:download_link) { viewable_row.find(:link, 'Download file (pdf, 1 KB)') }

        it 'links to the download endpoint and opens in the current tab' do
          expect(download_link[:href]).to eq '/documents/download?crime_application_id=12345&id=key1'
          expect(download_link[:target]).to be_nil
        end

        it 'applies GOV.UK summary list action styling' do
          expect(download_link[:class]).to match 'govuk-summary-list__actions-list-item'
        end
      end

      it 'displays both view and download links for files that can be viewed inline' do
        expect(viewable_row).to have_text(
          'document1.pdfViewDownload file (pdf, 1 KB)'
        )
      end

      it 'displays only the download link for files that cannot be viewed inline' do
        expect(non_viewable_row).to have_text(
          'document2.csvDownload file (csv, 2 KB)'
        )
      end
    end

    context 'when view_evidence feature flag is disabled' do
      before do
        allow(FeatureFlags).to receive(:view_evidence) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
        render_inline(described_class.new(crime_application:))
      end

      it 'displays only download links for all files when feature is disabled' do
        expect(viewable_row).to have_text('document1.pdfDownload file (pdf, 1 KB)')
        expect(non_viewable_row).to have_text('document2.csvDownload file (csv, 2 KB)')
      end
    end
  end
end

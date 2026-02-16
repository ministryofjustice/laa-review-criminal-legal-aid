require 'rails_helper'

RSpec.describe SupportingEvidenceComponent, type: :component do
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:supporting_evidence) { [] }

  before do
    allow(crime_application).to receive_messages(id: '12345', supporting_evidence: supporting_evidence)
  end

  describe '.new' do
    before { render_inline(described_class.new(crime_application:)) }

    describe 'card title' do
      subject { page.first('h2.govuk-summary-card__title').text }

      it { is_expected.to eq('Files') }
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
      let(:jpeg_evidence) do
        Document.new(
          filename: 'document2.jpg',
          content_type: 'image/jpeg',
          file_extension: 'jpg',
          file_size: 2048,
          s3_object_key: 'key2'
        )
      end
      let(:supporting_evidence) { [pdf_evidence, jpeg_evidence] }

      context 'when view_evidence feature flag is disabled' do
        before do
          allow(FeatureFlags).to receive(:view_evidence) {
            instance_double(FeatureFlags::EnabledFeature, enabled?: false)
          }
          render_inline(described_class.new(crime_application:))
        end

        it 'displays file names' do
          expect(page).to have_text('document1.pdf')
          expect(page).to have_text('document2.jpg')
        end

        it 'displays download links with file extension and size' do
          expect(page).to have_link(
            'Download file (pdf, 1 KB)', target: nil,
            href: %r{/documents/download\?.*crime_application_id=12345.*id=key1}
          )
          expect(page).to have_link(
            'Download file (jpg, 2 KB)', target: nil,
            href: %r{/documents/download\?.*crime_application_id=12345.*id=key2}
          )
        end
      end

      context 'when view_evidence feature flag is enabled' do
        before do
          allow(FeatureFlags).to receive(:view_evidence) {
            instance_double(FeatureFlags::EnabledFeature, enabled?: true)
          }
          render_inline(described_class.new(crime_application:))
        end

        it 'displays file names' do
          expect(page).to have_text('document1.pdf')
          expect(page).to have_text('document2.jpg')
        end

        it 'displays view links with visually hidden filename' do
          expect(page).to have_link(
            'View document1.pdf', target: '_blank',
            href: %r{/documents\?.*crime_application_id=12345.*id=key1}
          )
          expect(page).to have_link(
            'View document2.jpg', target: '_blank',
            href: %r{/documents\?.*crime_application_id=12345.*id=key2}
          )
        end
      end
    end
  end
end

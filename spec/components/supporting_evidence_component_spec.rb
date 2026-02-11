require 'rails_helper'

RSpec.describe SupportingEvidenceComponent, type: :component do
  let(:crime_application) { double }
  let(:supporting_evidence) { [] }

  before do
    allow(crime_application).to receive(:id).and_return('12345')
    allow(crime_application).to receive(:supporting_evidence).and_return(supporting_evidence)
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
      let(:evidence1) do
        double(
          filename: 'document1.pdf',
          file_extension: 'pdf',
          file_size: 1024,
          s3_object_key: 'key1'
        )
      end
      let(:evidence2) do
        double(
          filename: 'document2.jpg',
          file_extension: 'jpg',
          file_size: 2048,
          s3_object_key: 'key2'
        )
      end
      let(:supporting_evidence) { [evidence1, evidence2] }

      context 'when view_evidence feature flag is disabled' do
        before do
          allow(FeatureFlags).to receive(:view_evidence).and_return(double(enabled?: false))
          render_inline(described_class.new(crime_application:))
        end

        it 'displays file names' do
          expect(page).to have_text('document1.pdf')
          expect(page).to have_text('document2.jpg')
        end

        it 'displays download links with file extension and size' do
          expect(page).to have_link('Download file (pdf, 1 KB)')
          expect(page).to have_link('Download file (jpg, 2 KB)')
        end

        it 'links have correct paths' do
          expect(page).to have_link(href: /crime_application_id=12345/)
          expect(page).to have_link(href: /id=key1/)
          expect(page).to have_link(href: /id=key2/)
        end

        it 'links do not have target attribute' do
          expect(page.all('a').first[:target]).to eq('')
        end
      end

      context 'when view_evidence feature flag is enabled' do
        before do
          allow(FeatureFlags).to receive(:view_evidence).and_return(double(enabled?: true))
          render_inline(described_class.new(crime_application:))
        end

        it 'displays file names' do
          expect(page).to have_text('document1.pdf')
          expect(page).to have_text('document2.jpg')
        end

        it 'displays view links' do
          expect(page).to have_link('View', count: 2)
        end

        it 'links have target=_blank' do
          expect(page.all('a').first[:target]).to eq('_blank')
        end
      end
    end
  end
end

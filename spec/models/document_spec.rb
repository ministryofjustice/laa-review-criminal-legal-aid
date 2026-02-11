require 'rails_helper'

RSpec.describe Document do
  describe '#viewable_inline?' do
    subject(:document) do
      described_class.new(
        filename: 'test_file',
        content_type: content_type,
        file_extension: 'pdf',
        file_size: 1024,
        s3_object_key: 'test_key'
      )
    end

    context 'with PDF content type' do
      let(:content_type) { 'application/pdf' }

      it 'returns true as PDFs can be viewed inline in browsers' do
        expect(document).to be_viewable_inline
      end
    end

    context 'with JPEG image content type' do
      let(:content_type) { 'image/jpeg' }

      it 'returns true as JPEG images can be viewed inline in browsers' do
        expect(document).to be_viewable_inline
      end
    end

    context 'with PNG image content type' do
      let(:content_type) { 'image/png' }

      it 'returns true as PNG images can be viewed inline in browsers' do
        expect(document).to be_viewable_inline
      end
    end

    context 'with generic binary content type' do
      let(:content_type) { 'application/octet-stream' }

      it 'returns false as binary files cannot be safely viewed inline' do
        expect(document).not_to be_viewable_inline
      end
    end

    context 'with CSV content type' do
      let(:content_type) { 'text/csv' }

      it 'returns false as CSV files are not configured for inline viewing' do
        expect(document).not_to be_viewable_inline
      end
    end

    context 'with Word document content type' do
      let(:content_type) { 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' }

      it 'returns false as Word documents cannot be viewed inline in browsers' do
        expect(document).not_to be_viewable_inline
      end
    end

    context 'with empty string content type' do
      let(:content_type) { '' }

      it 'returns false when content type is missing' do
        expect(document).not_to be_viewable_inline
      end
    end
  end
end

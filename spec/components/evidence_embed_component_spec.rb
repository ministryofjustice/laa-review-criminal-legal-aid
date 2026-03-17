require 'rails_helper'

RSpec.describe EvidenceEmbedComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(evidence:, crime_application:)) }

  let(:crime_application) { instance_double(CrimeApplication, to_param: 'app-123') }

  context 'with a PDF document' do
    let(:evidence) do
      Document.new(
        filename: 'doc.pdf',
        content_type: 'application/pdf',
        file_extension: 'pdf',
        file_size: 1024,
        s3_object_key: 'key/pdf1'
      )
    end

    it 'renders an iframe pointing to the raw document path' do
      expect(rendered).to have_css(
        "iframe.app-evidence-embed--pdf[src*='key%2Fpdf1'][src*='raw']"
      )
    end

    it 'sets the iframe title to the filename' do
      expect(rendered).to have_css("iframe[title='doc.pdf']")
    end

    it 'does not render a download link' do
      expect(rendered).to have_no_link
    end
  end

  context 'with a viewable image document' do
    let(:evidence) do
      Document.new(
        filename: 'photo.png',
        content_type: 'image/png',
        file_extension: 'png',
        file_size: 512,
        s3_object_key: 'key/img1'
      )
    end

    it 'renders an img tag pointing to the raw document path' do
      expect(rendered).to have_css(
        "img.app-evidence-embed--image[src*='key%2Fimg1'][src*='raw']"
      )
    end

    it 'sets the alt text to the filename' do
      expect(rendered).to have_css("img[alt='photo.png']")
    end

    it 'does not render a download link' do
      expect(rendered).to have_no_link
    end
  end

  context 'with a non-embeddable document' do
    let(:evidence) do
      Document.new(
        filename: 'data.csv',
        content_type: 'application/octet-stream',
        file_extension: 'csv',
        file_size: 2048,
        s3_object_key: 'key/csv1'
      )
    end

    it 'displays the not embeddable message' do
      expect(rendered).to have_text('This file cannot be displayed in the browser.')
    end

    it 'renders a download link' do
      expect(rendered).to have_link(
        'Download file (csv, 2 KB)',
        href: /key%2Fcsv1/
      )
    end

    it 'does not render an iframe or img tag' do
      expect(rendered).to have_no_css('iframe')
      expect(rendered).to have_no_css('img')
    end
  end
end

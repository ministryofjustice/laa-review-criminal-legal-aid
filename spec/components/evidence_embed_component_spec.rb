require 'rails_helper'

RSpec.describe EvidenceEmbedComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(evidence:, crime_application:)) }

  let(:crime_application) { instance_double(CrimeApplication, to_param: 'app-123') }

  before do
    allow(FeatureFlags).to receive(:evidence_viewing_iteration) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }
  end

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

    it 'does not render rotate or zoom details' do
      expect(rendered).to have_no_text('Rotate or zoom')
    end

    context 'when on the supporting evidence tab page' do
      before { allow_any_instance_of(described_class).to receive(:show_view_link?).and_return(true) }

      it 'renders a "View in a new tab" link' do
        expect(rendered).to have_link('View in a new tab', href: /key%2Fpdf1/)
      end
    end

    context 'when not on the supporting evidence tab page' do
      before { allow_any_instance_of(described_class).to receive(:show_view_link?).and_return(false) }

      it 'does not render a "View in a new tab" link' do
        expect(rendered).to have_no_link('View in a new tab')
      end
    end

    context 'when evidence_viewing_iteration feature flag is disabled' do
      before do
        allow(FeatureFlags).to receive(:evidence_viewing_iteration) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
      end

      it 'renders an iframe pointing to the raw document path' do
        expect(rendered).to have_css(
          "iframe.app-evidence-embed--pdf[src*='key%2Fpdf1'][src*='raw']"
        )
      end

      it 'sets the iframe title to the filename' do
        expect(rendered).to have_css("iframe[title='doc.pdf']")
      end
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

    it 'renders rotate or zoom details' do # rubocop:disable RSpec/MultipleExpectations
      expect(rendered).to have_text('Rotate or zoom')
      expect(rendered).to have_text(
        'Hover over the image and press Ctrl twice, the image will open in the page. Use the controls to rotate or zoom.' # rubocop:disable Layout/LineLength
      )
      expect(rendered).to have_text(
        "Or, right click to open the menu, hover over 'More tools' and select Magnify to bring up rotate or zoom."
      )
    end

    context 'when on the documents index page' do
      before { allow_any_instance_of(described_class).to receive(:show_view_link?).and_return(true) }

      it 'renders a "View in a new tab" link' do
        expect(rendered).to have_link('View in a new tab', href: /key%2Fimg1/)
      end
    end

    context 'when not on the documents index page' do
      before { allow_any_instance_of(described_class).to receive(:show_view_link?).and_return(false) }

      it 'does not render a "View in a new tab" link' do
        expect(rendered).to have_no_link('View in a new tab')
      end
    end

    context 'when evidence_viewing_iteration feature flag is disabled' do
      before do
        allow(FeatureFlags).to receive(:evidence_viewing_iteration) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
      end

      it 'renders an img tag pointing to the raw document path' do
        expect(rendered).to have_css(
          "img.app-evidence-embed--image[src*='key%2Fimg1'][src*='raw']"
        )
      end

      it 'sets the alt text to the filename' do
        expect(rendered).to have_css("img[alt='photo.png']")
      end

      it 'does not render rotate or zoom details' do
        expect(rendered).to have_no_text('Rotate or zoom')
      end

      it 'does not render a "View in a new tab" link' do
        expect(rendered).to have_no_link('View in a new tab')
      end
    end
  end

  context 'with a non-viewable document' do
    before do
      allow(FeatureFlags).to receive(:evidence_viewing_iteration) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }
    end

    let(:evidence) do
      Document.new(
        filename: 'report.docx',
        content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        file_extension: 'docx',
        file_size: 1024,
        s3_object_key: 'key/docx1'
      )
    end

    it 'renders a not embeddable message' do
      expect(rendered).to have_text('This file cannot be displayed in the browser.')
    end
  end
end

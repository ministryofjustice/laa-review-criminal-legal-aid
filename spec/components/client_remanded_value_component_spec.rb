require 'rails_helper'

RSpec.describe ClientRemandedValueComponent, type: :component do
  describe '.new' do
    let(:raw_value) { nil }
    let(:tag_selector) { 'strong.govuk-tag.govuk-tag--red' }

    before do
      render_inline(described_class.new(raw_value:))
    end

    context 'when the value is `yes`' do
      let(:raw_value) { 'yes' }

      it 'renders the red "In court custody" tag' do
        class_element = page.first(tag_selector)
        expect(class_element.text).to eq('In court custody')
      end
    end

    context 'when the value is `no`' do
      let(:raw_value) { 'no' }

      it 'renders the text "No" and no tag' do
        expect(page.text).to eq('No')
        expect(page).to have_no_selector(tag_selector)
      end
    end
  end
end

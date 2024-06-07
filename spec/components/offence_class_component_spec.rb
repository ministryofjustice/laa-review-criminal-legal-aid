require 'rails_helper'

RSpec.describe OffenceClassComponent, type: :component do
  describe '.new' do
    let(:offence) do
      instance_double(LaaCrimeSchemas::Structs::Offence, offence_class:)
    end
    let(:tag_selector) { 'strong.govuk-tag.govuk-tag--red' }

    before do
      render_inline(described_class.new(offence:))
    end

    context 'when offence class in not determined' do
      let(:offence_class) { nil }

      it 'renders the "Not determined" tag' do
        class_element = page.first(tag_selector)
        expect(class_element.text).to eq('Not determined')
      end
    end

    context 'when offence class is present' do
      let(:offence_class) { 'A' }

      it 'prepends Class to class' do
        expect(page.text).to eq('Class A')
        expect(page).to have_no_selector(tag_selector)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ConflictOfInterestComponent, type: :component do
  describe '.new' do
    let(:codefendant) do
      instance_double(LaaCrimeSchemas::Structs::Codefendant, conflict_of_interest:)
    end
    let(:tag_selector) { 'strong.govuk-tag.govuk-tag--red' }

    before do
      render_inline(described_class.new(codefendant:))
    end

    context 'when no' do
      let(:conflict_of_interest) { 'no' }

      it 'renders the "No conflict" tag' do
        tag = page.first(tag_selector)
        expect(tag.text).to eq('No conflict')
      end
    end

    context 'when yes' do
      let(:conflict_of_interest) { 'yes' }

      it 'renders "Yes" and no tag' do
        expect(page.text).to eq('Yes')
        expect(page).to have_no_selector(tag_selector)
      end
    end
  end
end

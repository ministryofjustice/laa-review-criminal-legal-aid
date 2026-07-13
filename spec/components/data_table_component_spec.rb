# spec/components/data_table_component_spec.rb

require 'rails_helper'

RSpec.describe DataTableComponent, type: :component do
  before do
    render_inline(described_class.new)
  end

  describe 'table caption' do
    subject(:caption) { page.first('table > caption') }

    it 'renders a visually hidden sortable caption' do
      expect(caption).to have_css(
        '.govuk-visually-hidden',
        text: I18n.t('table_headings.sortable_caption')
      )
    end
  end
end

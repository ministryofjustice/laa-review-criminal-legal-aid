require 'rails_helper'

RSpec.describe DataTable::HeaderRowComponent, type: :component do
  subject(:component) { described_class.new(sorting:, filter:) }

  let(:sorting) { ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending') }
  let(:filter) { nil }

  describe 'caption' do
    before do
      render_inline(component) { |row| row.with_cell(colname: 'reference', text: 'Reference') }
    end

    it 'renders a visually hidden caption' do
      expect(page).to have_css('caption span.govuk-visually-hidden',
                               text: 'Column headers with buttons are sortable.')
    end
  end

  describe 'row structure' do
    before do
      render_inline(component) do |row|
        row.with_cell(colname: 'reference', text: 'Reference')
      end
    end

    it 'renders a tr with the govuk row class' do
      expect(page).to have_css('tr.govuk-table__row')
    end

    it 'renders cells as th elements' do
      expect(page).to have_css('th')
    end
  end

  describe 'cells' do
    context 'with multiple cells' do
      before do
        render_inline(component) do |row|
          row.with_cell(colname: 'reference', text: 'LAA Reference')
          row.with_cell(colname: 'caseworker', text: 'Caseworker')
          row.with_cell(colname: 'status', text: 'Status')
        end
      end

      it 'renders the correct number of th elements' do
        expect(page).to have_css('th', count: 3)
      end

      it 'renders cell text in order' do
        expect(page.all('th').map(&:text)).to eq(['LAA Reference', 'Caseworker', 'Status'])
      end
    end

    context 'with a numeric cell' do
      before do
        render_inline(component) do |row|
          row.with_cell(colname: 'reference', text: 'Reference', numeric: true)
        end
      end

      it 'applies the numeric header class' do
        expect(page).to have_css('th.govuk-table__header--numeric')
      end
    end

    context 'with a custom colspan' do
      before do
        render_inline(component) do |row|
          row.with_cell(colname: 'reference', text: 'Reference', colspan: 3)
        end
      end

      it 'sets the colspan attribute' do
        expect(page).to have_css('th[colspan="3"]')
      end
    end

    context 'with a non-sortable column' do
      before do
        render_inline(component) do |row|
          row.with_cell(colname: 'reference', text: 'Reference')
        end
      end

      it 'does not set aria-sort on the th' do
        expect(page).to have_css('th:not([aria-sort])')
      end

      it 'renders plain text, not a button' do
        expect(page).not_to have_button('Reference')
      end
    end

    context 'with a sortable column that is not active' do
      before do
        render_inline(component) do |row|
          row.with_cell(colname: 'applicant_name', text: 'Name')
        end
      end

      it 'sets aria-sort to none on the th' do
        expect(page).to have_css('th[aria-sort="none"]')
      end

      it 'renders a link' do
        expect(page).to have_link('Name', class: 'govuk-link')
      end
    end

    context 'with the active sort column' do
      let(:sorting) { ApplicationSearchSorting.new(sort_by: 'applicant_name', sort_direction: 'ascending') }

      before do
        render_inline(component) do |row|
          row.with_cell(colname: 'applicant_name', text: 'Name')
        end
      end

      it 'sets aria-sort to the current sort direction' do
        expect(page).to have_css('th[aria-sort="ascending"]')
      end

      it 'renders a link with the column text' do
        expect(page).to have_link('Name', class: 'govuk-link')
      end
    end

    context 'when the active column is sorted descending' do
      let(:sorting) { ApplicationSearchSorting.new(sort_by: 'applicant_name', sort_direction: 'descending') }

      before do
        render_inline(component) do |row|
          row.with_cell(colname: 'applicant_name', text: 'Name')
        end
      end

      it 'sets aria-sort to descending' do
        expect(page).to have_css('th[aria-sort="descending"]')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe DataTable::HeaderCellComponent, type: :component do
  subject(:component) do
    described_class.new(
      colname: colname,
      scope: 'col',
      colspan: 1,
      sorting: sorting,
      filter: nil,
      numeric: false,
      text: nil
    )
  end

  let(:sorting) { ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'ascending') }

  context 'when the column is not sortable' do
    let(:colname) { :caseworker }

    before { render_inline(component) }

    it 'renders a th with the column heading text and no aria-sort' do
      expect(page).to have_css('th.govuk-table__header:not([aria-sort])', text: 'Caseworker')
    end
  end

  context 'when the column is sortable but not the active sort' do
    let(:colname) { :applicant_name }

    before { render_inline(component) }

    it 'renders a th with aria-sort="none" and a sort link' do
      expect(page).to have_css('th.govuk-table__header[aria-sort="none"]')
      expect(page).to have_link(text: 'Applicant\'s name', class: 'govuk-link')
    end
  end

  context 'when the column is the active sort column' do
    let(:colname) { :submitted_at }
    let(:sorting) { ApplicationSearchSorting.new(sort_by: 'submitted_at', sort_direction: 'descending') }

    before { render_inline(component) }

    it 'renders a th with aria-sort set to the current sort direction' do
      expect(page).to have_css('th.govuk-table__header[aria-sort="descending"]')
      expect(page).to have_link(text: 'Date received', class: 'govuk-link')
    end
  end
end

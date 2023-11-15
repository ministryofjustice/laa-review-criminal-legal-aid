require 'rails_helper'

RSpec.shared_examples 'a table with sortable headers' do
  it 'contains the expected active sortable headers' do
    active = page.all("thead tr th[aria-sort=#{active_sort_direction}]").map(&:text)
    expect(active).to match_array(active_sort_headers)
  end

  it 'contains the expected inactive sortable headers' do
    non_active = page.all('thead tr th[aria-sort=none]').map(&:text)
    expect(non_active).to match_array(inactive_sort_headers)
  end

  describe 'when the active header is clicked' do
    it 'reverses the sort direction' do
      text = active_sort_headers.first
      expect { click_button text }.to change {
        page.find('thead tr th', text:)['aria-sort']
      }.from(active_sort_direction)
    end
  end

  describe 'when an inactive header is clicked' do
    it 'they become active' do
      inactive_sort_headers.each do |text|
        expect { click_button text }.to change {
          page.find('thead tr th', text:)['aria-sort']
        }.from('none')
      end
    end
  end
end

RSpec.shared_examples 'a table with sortable columns' do
  it 'contains the expected active sortable headers' do
    active = page.all("thead tr th[aria-sort=#{active_direction}]").pluck(:id)
    expect(active).to match_array(active)
  end

  it 'contains the expected inactive sortable headers' do
    non_active = page.all('thead tr th[aria-sort=none]').pluck(:id)
    expect(non_active).to match_array(inactive)
  end

  describe 'when the active header is clicked' do
    it 'reverses the sort direction' do
      colname = active.first
      expect { page.find("th##{colname} button").click }.to change {
        page.find("th##{colname}")['aria-sort']
      }.from(active_direction)
    end
  end

  describe 'when an inactive header is clicked' do
    it 'they become active' do
      inactive.each do |colname|
        expect { page.find("th##{colname} button").click }.to change {
          page.find("th##{colname}")['aria-sort']
        }.from('none')
      end
    end
  end
end

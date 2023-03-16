require 'rails_helper'

RSpec.describe 'Accessibility' do
  before { driven_by(:headless_chrome) }

  describe 'Start page' do
    it 'has no AXE-detectable accessibility issues' do
      visit '/'
      expect(page).to be_axe_clean
    end
  end
end

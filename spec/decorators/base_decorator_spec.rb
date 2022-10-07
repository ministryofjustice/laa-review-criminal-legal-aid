require 'rails_helper'

RSpec.describe BaseDecorator do
  describe '.decorate' do
    it 'calls the helper method passing self' do
      allow(ApplicationController.helpers).to receive(:decorate)

      described_class.decorate('foobar')

      expect(
        ApplicationController.helpers
      ).to have_received(:decorate).with('foobar', described_class)
    end
  end
end

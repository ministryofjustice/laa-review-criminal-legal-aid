require 'rails_helper'

RSpec.describe BaseDecorator do
  describe '.decorate' do
    before do
      allow(ApplicationController.helpers).to receive(:decorate).with('foobar', described_class)
    end

    it 'calls the helper method passing self' do
      described_class.decorate('foobar')

      expect(
        ApplicationController.helpers
      ).to have_received(:decorate).with('foobar', described_class)
    end
  end
end

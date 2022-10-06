require 'rails_helper'

RSpec.describe BasePresenter do
  describe '.present' do
    it 'calls the helper method passing self' do
      described_class.present('foobar')

      expect(
        ApplicationController.helpers
      ).to have_received(:present).with('foobar', described_class)
    end
  end
end

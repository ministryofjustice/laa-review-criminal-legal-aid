require 'rails_helper'

RSpec.describe Reporting::CurrentOpenApplications do

  subject(:report) { described_class.new }
  describe 'counts' do
    subject(:counts) { report.counts }

    it 'returns a count of open applications by day' do
      throw counts
      expect(counts).to be 4
    end
  end
end

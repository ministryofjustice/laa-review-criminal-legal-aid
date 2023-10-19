require 'rails_helper'

describe Reporting::TemporalReport do
  let(:interval) { :weekly }
  let(:report_type) { :interval }

  describe '.from_param' do
    subject(:report_from_param) do
      described_class.from_param(report_type: 'volumes_report', period: '2023-August', interval: 'monthly')
    end

    it 'returns the correct report from the param' do
      expect(report_from_param.title).to eq('Volumes monthly: August, 2023')
    end
  end

  describe '.current' do
    subject(:curent_report) do
      described_class.current(report_type: 'caseworker_report', interval: 'monthly')
    end

    it 'returns the correct report from the param' do
      expected = described_class._current_date.strftime('Caseworker monthly: %B, %Y')
      expect(curent_report.title).to eq expected
    end
  end
end

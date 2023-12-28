require 'rails_helper'

RSpec.shared_examples 'a temporal report' do
  describe '#title' do
    subject(:title) { report.title }

    it { is_expected.to eq expected_title }
  end

  describe '#to_param' do
    subject(:to_param) { report.to_param }

    it { is_expected.to eq expected_to_param }
  end

  describe '#id' do
    subject(:id) { report.id }

    it { is_expected.to eq expected_id }
  end

  describe '#period_text' do
    subject(:period_text) { report.period_text }

    it { is_expected.to eq expected_period_text }
  end

  describe '#next_report' do
    subject(:next_report) { report.next_report }

    it 'returns the next report' do
      expected_time_period = Reporting::TimePeriod.new(
        interval: time_period.interval,
        date: expected_next_report_date
      )
      expect(next_report.time_period).to eq(expected_time_period)
    end
  end

  describe '#previous_report' do
    subject(:previous_report) { report.previous_report }

    it 'returns the previous report' do
      expected_time_period = Reporting::TimePeriod.new(
        interval: time_period.interval,
        date: expected_previous_report_date
      )
      expect(previous_report.time_period).to eq(expected_time_period)
    end
  end

  describe '#current?' do
    let(:date) { Time.current.in_time_zone('London').to_date }

    it 'returns true if the report includes the current day' do
      expect(report.current?).to be true
    end

    it 'returns false if report does not include the current date' do
      expect(report.next_report.current?).to be false
      expect(report.previous_report.current?).to be false
    end
  end
end

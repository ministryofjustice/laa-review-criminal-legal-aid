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

  describe '#period_text' do
    subject(:period_text) { report.period_text }

    it { is_expected.to eq expected_period_text }
  end

  describe '#next_report' do
    subject(:next_report) { report.next_report }

    it 'returns the next report' do
      expect(next_report.date).to eq(expected_next_report_date)
    end
  end

  describe '#previous_report' do
    subject(:previous_report) { report.previous_report }

    it 'returns the previous report' do
      expect(previous_report.date).to eq(expected_previous_report_date)
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

  describe '#rows' do
    it 'fetches the rows from the report_type\'s read model using the correct temporal stream name' do
      read_model = instance_double(Reporting::CaseworkerReport, rows: :read_model_rows)

      allow(Reporting::CaseworkerReport).to receive(:new).with(stream_name: expected_stream_name) {
        read_model
      }

      expect(report.rows).to eq :read_model_rows
    end
  end
end

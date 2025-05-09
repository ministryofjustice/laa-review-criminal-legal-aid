require 'rails_helper'

RSpec.describe GenerateDownloadableTemporalReportJob, type: :job do
  it 'is in reports queue' do
    expect(described_class.new.queue_name).to eq('reports')
  end

  describe 'generating caseworker reports' do
    subject(:job) { described_class.perform_now(report_type, period) }

    let(:report_type) { 'caseworker_report' }

    before do
      travel_to Time.zone.local(2025, 5, 8)
      job
    end

    describe 'for the previous month' do
      let(:period) { 'monthly' }

      it 'creates one report record' do
        expect(GeneratedReport.count).to eq(1)
      end

      it 'creates a report record with the right attributes' do # rubocop:disable RSpec/MultipleExpectations
        generated_report = GeneratedReport.first
        expect(generated_report.report_type).to eq('caseworker_report')
        expect(generated_report.interval).to eq('monthly')
        expect(generated_report.period_start_date).to eq(Date.parse('2025-04-01'))
        expect(generated_report.period_end_date).to eq(Date.parse('2025-04-30'))
      end

      it 'attaches a report CSV to the record' do # rubocop:disable RSpec/MultipleExpectations
        report_file = GeneratedReport.first.report
        expect(report_file).not_to be_nil
        expect(report_file.filename).to eq('caseworker_report_monthly_2025-April.csv')
        expect(report_file.content_type).to eq('text/csv')
      end
    end

    describe 'for the previous week' do
      let(:period) { 'weekly' }

      it 'creates one report record' do
        expect(GeneratedReport.count).to eq(1)
      end

      it 'creates a report record with the right attributes' do # rubocop:disable RSpec/MultipleExpectations
        generated_report = GeneratedReport.first
        expect(generated_report.report_type).to eq('caseworker_report')
        expect(generated_report.interval).to eq('weekly')
        expect(generated_report.period_start_date).to eq(Date.parse('2025-04-28'))
        expect(generated_report.period_end_date).to eq(Date.parse('2025-05-04'))
      end

      it 'attaches a report CSV to the record' do # rubocop:disable RSpec/MultipleExpectations
        report_file = GeneratedReport.first.report
        expect(report_file).not_to be_nil
        expect(report_file.filename).to eq('caseworker_report_weekly_2025-18.csv')
        expect(report_file.content_type).to eq('text/csv')
      end
    end

    describe 'for the previous day' do
      let(:period) { 'daily' }

      it 'creates one report record' do
        expect(GeneratedReport.count).to eq(1)
      end

      it 'creates a report record with the right attributes' do # rubocop:disable RSpec/MultipleExpectations
        generated_report = GeneratedReport.first
        expect(generated_report.report_type).to eq('caseworker_report')
        expect(generated_report.interval).to eq('daily')
        expect(generated_report.period_start_date).to eq(Date.parse('2025-05-07'))
        expect(generated_report.period_end_date).to eq(Date.parse('2025-05-07'))
      end

      it 'attaches a report CSV to the record' do # rubocop:disable RSpec/MultipleExpectations
        report_file = GeneratedReport.first.report
        expect(report_file).not_to be_nil
        expect(report_file.filename).to eq('caseworker_report_daily_2025-05-07.csv')
        expect(report_file.content_type).to eq('text/csv')
      end
    end
  end
end

require 'rails_helper'

describe Reporting::TemporalReport do
  let(:interval) { :weekly }
  let(:report_type) { :interval }

  describe '.from_param' do
    subject(:report_from_param) do
      described_class.from_param(report_type: 'return_reasons_report', period: '2023-August', interval: 'monthly')
    end

    it 'returns the correct report from the param' do
      expect(report_from_param.title).to eq('Return reasons monthly: August 2023')
    end
  end

  describe '.current' do
    subject(:curent_report) do
      described_class.current(report_type: 'caseworker_report', interval: 'monthly')
    end

    it 'returns the correct report from the param' do
      expected = described_class._current_date.strftime('Caseworker monthly: %B %Y')
      expect(curent_report.title).to eq expected
    end
  end

  describe 'report_params forwarding' do
    let(:time_period) { Reporting::TimePeriod.new(interval: 'monthly', date: Date.new(2024, 1, 1)) }
    let(:report) do
      Reporting::MonthlyReport.new(
        time_period: time_period,
        report_type: 'caseworker_report',
        user_id: 'abc-123',
        some_other_param: 'value'
      )
    end

    it 'stores extra keyword args as report_params' do
      expect(report.report_params).to eq(user_id: 'abc-123', some_other_param: 'value')
    end

    describe '#to_param' do
      it 'merges report_params into the routing hash' do
        expect(report.to_param).to include(user_id: 'abc-123', some_other_param: 'value')
      end

      it 'does not add filter or sorting parameters to existing report URLs' do
        expect(report.to_param.keys).to eq(%i[report_type interval period user_id some_other_param])
      end
    end

    describe '#frame_id' do
      it 'retains the user identifier' do
        expect(report.frame_id).to eq('caseworker_report_monthly_2024-January_abc-123_value')
      end
    end

    describe '#next_report' do
      it 'propagates report_params' do
        expect(report.next_report.report_params).to eq(report.report_params)
      end
    end

    describe '#previous_report' do
      it 'propagates report_params' do
        expect(report.previous_report.report_params).to eq(report.report_params)
      end
    end

    describe '.from_param' do
      it 'forwards extra kwargs as report_params' do
        result = described_class.from_param(
          report_type: 'caseworker_report',
          period: '2024-January',
          interval: 'monthly',
          user_id: 'abc-123'
        )
        expect(result.report_params).to eq(user_id: 'abc-123')
      end
    end

    describe '.current' do
      it 'forwards extra kwargs as report_params' do
        result = described_class.current(
          report_type: 'caseworker_report',
          interval: 'monthly',
          user_id: 'abc-123'
        )
        expect(result.report_params).to eq(user_id: 'abc-123')
      end
    end
  end

  describe 'slipstream report links and identity' do
    let(:report) do
      described_class.from_param(
        report_type: 'slipstream_audit_report', interval: 'monthly', period: '2025-October',
        offence: 'Burglary', sorting: { sort_by: 'office_code', sort_direction: 'descending' }
      )
    end

    it 'serializes the filter and sorting in the controller format' do
      expect(report.to_param).to eq(
        report_type: 'slipstream_audit_report', interval: 'monthly', period: '2025-October',
        filter: { offence: 'Burglary' }, sorting: { sort_by: 'office_code', sort_direction: 'descending' }
      )
    end

    it 'keeps the original filename identity' do
      expect(report.id).to eq('slipstream_audit_report_monthly_2025-October_Burglary')
    end

    it 'excludes filter and sorting from the frame identity' do
      expect(report.frame_id).to eq('slipstream_audit_report_monthly_2025-October')
    end

    it 'preserves the nested filter in adjacent month links' do
      links = [report.previous_report, report.next_report].map(&:to_param)
      expect(links).to all(include(filter: { offence: 'Burglary' }))
    end
  end
end

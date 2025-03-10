require 'rails_helper'

RSpec.describe Reporting::Snapshot do
  subject(:snapshot) do
    described_class.new(report_type:, observed_at:)
  end

  let(:report_type) { Types::Report['workload_report'] }
  let(:observed_at) { Time.zone.local(2023, 10, 9, 11, 11) }

  let(:example_params) do
    {
      report_type: 'workload_report',
      date: '2023-10-09',
      time: '12:11'
    }
  end

  describe '#to_param' do
    subject(:to_param) { snapshot.to_param }

    it 'is a hash of "report_type", "date", and "time"' do
      expect(to_param).to eq example_params
    end
  end

  describe 'observed_business_period_text' do
    subject(:text) do
      snapshot.observed_business_period_text
    end

    context 'when observed business day follows a non-working day' do
      it 'shows the start and end days and times' do
        expect(text).to eq 'midnight Saturday to 12:11pm Monday'
      end
    end

    context 'when observed business day follows a business day' do
      let(:observed_at) { Time.zone.local(2023, 10, 11, 11, 11) }

      it 'shows the start and end time' do
        expect(text).to eq 'midnight until 12:11pm'
      end
    end
  end

  describe '.from_param' do
    let(:from_param) { described_class.from_param(**example_params) }

    it 'initialize a snapshot based on the params' do
      expect(from_param.to_param).to eq(example_params)
    end

    context 'with invalid date params' do
      let(:example_params) { super().merge(date: '2023-13-10') }

      it 'raises Reporting::ReportNotFound' do
        expect { from_param }.to raise_error Reporting::ReportNotFound
      end
    end

    context 'with an unsupported report_type' do
      let(:example_params) { super().merge(report_type: Types::Report['caseworker_report']) }

      it 'raises Reporting::ReportNotFound' do
        expect { from_param }.to raise_error Reporting::ReportNotFound
      end
    end
  end
end

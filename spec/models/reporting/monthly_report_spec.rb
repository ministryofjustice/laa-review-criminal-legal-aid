require 'rails_helper'

describe Reporting::MonthlyReport do
  subject(:report) { described_class.new(date:, report_type:) }

  let(:date) { Date.new(2023, 8, 1) }
  let(:report_type) { 'caseworker_report' }

  it_behaves_like 'a temporal report' do
    let(:date) { Date.new(2023, 8, 1) }
    let(:expected_stream_name) { 'MonthlyCaseworker$2023-08' }
    let(:expected_period_text) { 'Tuesday 1 — Thursday 31 August 2023' }
    let(:expected_title) { 'Caseworker monthly: August, 2023' }
    let(:expected_to_param) { { interval: 'monthly', period: '2023-August', report_type: 'caseworker_report' } }
    let(:expected_period_name) { 'August, 2023' }
    let(:expected_next_report_date) { Date.new(2023, 9, 1) }
    let(:expected_previous_report_date) { Date.new(2023, 7, 1) }
  end
end

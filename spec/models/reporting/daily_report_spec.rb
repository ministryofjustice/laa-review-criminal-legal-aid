require 'rails_helper'

describe Reporting::DailyReport do
  subject(:report) { described_class.new(date:, report_type:) }

  let(:date) { Date.new(2023, 8, 1) }
  let(:report_type) { 'caseworker_report' }

  it_behaves_like 'a temporal report' do
    let(:expected_stream_name) { 'DailyCaseworker$2023-213' }
    let(:expected_period_text) { '00:00—23:59' }
    let(:expected_title) { 'Caseworker daily: Tuesday 1 August 2023' }
    let(:expected_to_param) { '2023-08-01' }
    let(:expected_period_name) { 'Tuesday 1 August 2023' }
    let(:expected_next_report_date) { date + 1 }
    let(:expected_previous_report_date) { date - 1 }
  end
end
require 'rails_helper'

describe Reporting::WeeklyReport do
  subject(:report) { described_class.new(date:, report_type:) }

  let(:date) { Date.new(2023, 8, 1) }
  let(:report_type) { 'caseworker_report' }

  it_behaves_like 'a temporal report' do
    let(:date) { Date.new(2023, 8, 1) }
    let(:expected_stream_name) { 'WeeklyCaseworker$2023-31' }
    let(:expected_period_text) { 'Monday 31 July 2023 — Sunday 6 August 2023' }
    let(:expected_title) { 'Caseworker weekly: Week 31, 2023' }
    let(:expected_to_param) { '2023-31' }
    let(:expected_period_name) { 'August, 2023' }
    let(:expected_next_report_date) { Date.new(2023, 8, 8) }
    let(:expected_previous_report_date) { Date.new(2023, 7, 25) }
  end
end
require 'rails_helper'

describe Reporting::UnassignedFromSelfReport do
  let(:target_user_id) { 'user-uuid-1' }
  let(:other_user_id) { 'user-uuid-2' }
  let(:dataset) do
    {
      target_user_id => { user_id: target_user_id, assignment_ids: %w[app-1 app-2] },
      other_user_id => { user_id: other_user_id, assignment_ids: %w[app-3] }
    }
  end

  describe '#rows' do
    context 'without a user_id' do
      subject(:report) { described_class.new(dataset:) }

      it 'returns all users rows' do
        expect(report.rows).to eq(dataset.values)
      end
    end

    context 'with a known user_id' do
      subject(:report) { described_class.new(dataset: dataset, user_id: target_user_id) }

      it 'returns the assignment_ids for that user' do
        expect(report.rows).to eq(%w[app-1 app-2])
      end
    end

    context 'with an unknown user_id' do
      subject(:report) { described_class.new(dataset: dataset, user_id: 'unknown-user') }

      it 'returns an empty array' do
        expect(report.rows).to eq([])
      end
    end
  end

  describe '.for_time_period' do
    let(:time_period) { Reporting::TimePeriod.new(interval: 'monthly', date: Date.new(2024, 1, 1)) }

    before do
      allow(CaseworkerReports::UnassignedFromSelfProjection)
        .to receive(:new).and_return(
          instance_double(
            CaseworkerReports::UnassignedFromSelfProjection, dataset:
          )
        )
    end

    it 'accepts a user_id keyword argument without raising' do
      expect do
        described_class.for_time_period(time_period: time_period, user_id: target_user_id)
      end.not_to raise_error
    end

    it 'accepts unknown keyword arguments without raising' do
      expect do
        described_class.for_time_period(time_period: time_period, user_id: target_user_id, some_future_param: true)
      end.not_to raise_error
    end

    it 'passes user_id to the report instance, returning that user\'s assignment_ids' do
      report = described_class.for_time_period(time_period: time_period, user_id: target_user_id)
      expect(report.rows).to eq(%w[app-1 app-2])
    end

    it 'returns all rows when no user_id is given' do
      report = described_class.for_time_period(time_period:)
      expect(report.rows).to eq(dataset.values)
    end
  end
end

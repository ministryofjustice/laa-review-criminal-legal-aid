require 'rails_helper'

describe Reporting::UnassignedFromSelfReport do
  describe '.for_time_period' do
    let(:time_period) { Reporting::TimePeriod.new(interval: 'monthly', date: Date.new(2024, 1, 1)) }

    it 'accepts a user_id keyword argument without raising' do
      allow(CaseworkerReports::UnassignedFromSelfProjection)
        .to receive(:new).and_return(double(dataset: {}))

      expect do
        described_class.for_time_period(time_period: time_period, user_id: 'abc-123')
      end.not_to raise_error
    end

    it 'accepts unknown keyword arguments without raising' do
      allow(CaseworkerReports::UnassignedFromSelfProjection)
        .to receive(:new).and_return(double(dataset: {}))

      expect do
        described_class.for_time_period(time_period: time_period, user_id: 'abc-123', some_future_param: true)
      end.not_to raise_error
    end
  end
end

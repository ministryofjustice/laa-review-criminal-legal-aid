require 'rails_helper'

RSpec.describe Reporting::ReceivedOnReport do
  describe '#total_open' do
    subject(:total_open) { record.total_open }

    context 'when new' do
      let(:record) { described_class.new }

      it { is_expected.to be_zero }
    end

    context 'with 100 received and 512 closed' do
      let(:record) { described_class.new(total_received: 100, total_closed: 51) }

      it { is_expected.to be 49 }
    end
  end

  it 'is a read only model' do
    expect(described_class.new).to be_readonly
  end
end

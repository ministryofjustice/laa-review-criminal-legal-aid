require 'rails_helper'

RSpec.describe Maat::Decision do
  describe '.new' do
    subject(:new) { described_class.new(response) }

    let(:response) do
      {
        'usn' => 10,
        'maat_ref' => 600,
        'case_id' => '123123123',
        'case_type' => 'SUMMARY ONLY',
        'ioj_result' => 'PASS',
        'ioj_assessor_name' => 'System Test IoJ',
        'ioj_reason' => 'Details of IoJ',
        'app_created_date' => '2024-09-23T00:00:00',
        'means_result' => 'PASS',
        'means_assessor_name' => 'System Test Means',
        'date_means_created' => '2024-09-23T17:18:56',
        'funding_decision' => 'GRANTED'
      }
    end

    describe '#usn' do
      subject(:usn) { new.usn }

      it { is_expected.to be 10 }
    end

    describe '#maat_ref' do
      subject(:maat_ref) { new.maat_ref }

      it { is_expected.to be 600 }
    end

    describe '#case_id' do
      subject(:case_id) { new.case_id }

      it { is_expected.to eq '123123123' }
    end

    describe '#case_type' do
      subject(:case_type) { new.case_type }

      it { is_expected.to eq 'SUMMARY ONLY' }
    end

    describe '#ioj_result' do
      subject(:ioj_result) { new.ioj_result }

      it { is_expected.to eq 'PASS' }
    end

    describe '#ioj_assessor_name' do
      subject(:ioj_assessor_name) { new.ioj_assessor_name }

      it { is_expected.to eq 'System Test IoJ' }
    end

    describe '#ioj_reason' do
      subject(:ioj_reason) { new.ioj_reason }

      it { is_expected.to eq 'Details of IoJ' }
    end

    describe '#app_created_date' do
      subject(:app_created_date) { new.app_created_date }

      it { is_expected.to eq '2024-09-23T00:00:00' }
    end

    describe '#means_result' do
      subject(:means_result) { new.means_result }

      it { is_expected.to eq 'PASS' }
    end

    describe '#means_assessor_name' do
      subject(:means_assessor_name) { new.means_assessor_name }

      it { is_expected.to eq 'System Test Means' }
    end

    describe '#date_means_created' do
      subject(:date_means_created) { new.date_means_created }

      it { is_expected.to eq '2024-09-23T17:18:56' }
    end

    describe '#funding_decision' do
      subject(:funding_decision) { new.funding_decision }

      it { is_expected.to eq 'GRANTED' }
    end
  end
end

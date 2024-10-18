require 'rails_helper'

RSpec.describe Maat::Decision do
  describe '.build()' do
    subject(:build) { described_class.build(response) }

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

    it 'returns an instance of a Maat::Decision' do
      expect(build).to be_a described_class
    end

    it 'sets the interests of justice' do
      expect(build.interests_of_justice.attributes).to eq(
        assessed_by: 'System Test IoJ',
        assessed_on: Date.new(2024, 9, 23),
        details: 'Details of IoJ',
        result: 'pass'
      )
    end

    it 'sets the means' do
      expect(build.means.attributes).to eq(
        assessed_by: 'System Test Means',
        assessed_on: Date.new(2024, 9, 23),
        result: 'pass'
      )
    end

    it 'sets the funding decision' do
      expect(build.funding_decision).to eq('granted')
    end
  end
end

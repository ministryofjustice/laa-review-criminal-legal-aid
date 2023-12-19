require 'rails_helper'

describe WorkStream do
  describe '.all' do
    subject(:all) { described_class.all }

    it 'returns a list of all work streams' do
      expect(all.map(&:to_s)).to eq Types::WorkStreamType.values
    end
  end

  describe 'comparing' do
    let(:extradition_a) { described_class.new('extradition') }
    let(:extradition_b) { described_class.new('extradition') }
    let(:cat1_a) { described_class.new('criminal_applications_team') }
    let(:cat2_a) { described_class.new('criminal_applications_team_2') }
    let(:cat2_b) { described_class.new('criminal_applications_team_2') }

    describe '#==' do
      it 'returns true if the work streams objects have the same value' do
        expect(extradition_a == extradition_b).to be true
        expect(cat2_a == cat2_b).to be true
      end

      it 'returns true when compared to a string with the same value' do
        expect(extradition_b == 'extradition').to be true
      end

      it 'returns false if the work streams have a different value' do
        expect(cat2_a == cat1_a).to be false
      end
    end

    describe '#eql?' do
      it 'returns true if the work streams objects have the same value' do
        expect(extradition_a.eql?(extradition_b)).to be true
      end

      it 'returns true when compared to a string with the same value' do
        expect(extradition_b.eql?('extradition')).to be true
      end

      it 'returns false if the work streams have a different value' do
        expect(cat2_a.eql?(cat1_a)).to be false
      end
    end

    it 'then intersection between two arrays can be compared' do
      expect([extradition_a, cat2_a] & [cat2_b, cat1_a]).to eq [cat2_a]
    end

    it 'then union between two arrays can be compared' do
      expect([extradition_a, cat2_a] | [cat2_b, cat1_a]).to eq [extradition_a, cat2_a, cat1_a]
    end
  end
end

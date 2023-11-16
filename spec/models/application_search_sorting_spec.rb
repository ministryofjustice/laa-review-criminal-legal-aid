require 'rails_helper'

RSpec.describe ApplicationSearchSorting do
  describe '#reverse_direction' do
    context 'when sort direction is ascending' do
      let(:sorting) { described_class.new(sort_direction: 'ascending') }

      it 'returns descending' do
        expect(sorting.reverse_direction).to eq('descending')
      end
    end

    context 'when sort direction is descending' do
      let(:sorting) { described_class.new(sort_direction: 'descending') }

      it 'returns ascending' do
        expect(sorting.reverse_direction).to eq('ascending')
      end
    end
  end

  describe 'attributes' do
    let(:sort_direction) { 'descending' }
    let(:sort_by) { 'time_passed' }

    let(:sorting) do
      described_class.new(
        sort_direction:,
        sort_by:
      )
    end

    it 'has a sort_direction attribute' do
      expect(sorting).to respond_to(:sort_direction)
    end

    it 'has a sort_by attribute' do
      expect(sorting).to respond_to(:sort_by)
    end

    describe 'error states' do
      describe 'sort_by error' do
        let(:sort_by) { 'alphabetical' }

        it 'errors if there is an incorrect value is given for sort_by' do
          expect { sorting }.to raise_exception Dry::Struct::Error
        end
      end

      describe 'sort_direction error' do
        let(:sort_direction) { 'oldest_first' }

        it 'errors if there is an incorrect value is given for sort_by' do
          expect { sorting }.to raise_exception Dry::Struct::Error
        end
      end
    end
  end
end

require 'rails_helper'

# Required logic for counting in business days.
# Example given for a week with a bank holiday Monday, viewed on Wednesday.
#
# event_date    | 29/12 | 30/12 | 31/01 | 1/1 | 2/1 | 3/1 | 4/1 |
#               |  thu  |  fri  |  sat  | sun | mon | tue | wed |
# age_in_days   |   3   |   2   |   1   |  1  |  1  |  1  |  0  |
# starts_on     |  thu  |  fri  |  sat  | sat | sat | sat | wed |
# ends_before   |  fri  |  sat  |  wed  | wed | wed | wed | nil |
#
# something that arrives on Friday, is 1 day old on Monday
# something that arrives on Saturday, is 0 days old on Monday

RSpec.describe BusinessDay do
  let(:day_zero) { Date.parse('2023-01-04') }

  describe '.new' do
    subject(:business_day) do
      described_class.new(day_zero:)
    end

    describe '#date' do
      context 'when day_zero is a business day' do
        let(:day_zero) { '2023-01-04' }

        it 'returns the day_zero date' do
          expect(business_day.date).to eq(Date.parse(day_zero))
        end
      end

      context 'when day_zero is not a business day' do
        let(:day_zero) { '2023-01-01' }

        it 'returns the following day_zero date' do
          expect(business_day.date).to eq(Date.new(2023, 1, 3))
        end
      end
    end

    context 'when date_zero is given as a time' do
      context 'when BST' do
        it 'converts the time to the corresponding date in TZ London' do
          expect(described_class.new(day_zero: '2023-07-07T23:04:35.351Z')).to eq('2023-07-10')
          expect(described_class.new(day_zero: '2023-07-07T22:59:35.351Z')).to eq('2023-07-07')
        end
      end

      context 'when GMT' do
        it 'converts the time to the corresponding date in TZ London' do
          expect(described_class.new(day_zero: '2022-12-31T00:00:35.351Z')).to eq('2023-01-03')
          expect(described_class.new(day_zero: '2022-12-30T23:59:35.351Z')).to eq('2022-12-30')
        end
      end
    end

    describe '#starts_on' do
      subject(:starts_on) { business_day.starts_on }

      context 'when day_zero is a business day that follows a working day' do
        let(:day_zero) { Date.parse('2023-01-05') }

        it 'returns the day zero date' do
          expect(starts_on).to eq(day_zero)
        end
      end

      context 'when day_zero is a Sunday' do
        let(:day_zero) { Date.parse('2023-01-01') }

        it 'returns Saturday' do
          expect(starts_on).to eq(Date.parse('2022-12-31'))
        end
      end

      context 'when day_zero is the Tuesday after a bank holiday' do
        let(:day_zero) { Date.parse('2023-01-03') }

        it 'returns Saturday' do
          expect(starts_on).to eq(Date.parse('2022-12-31'))
        end
      end
    end

    describe '==(other)' do
      it 'business days with different day zero but the same business day are equal' do
        a = described_class.new(day_zero: '2023-01-03')
        b = described_class.new(day_zero: '2023-01-01')

        expect(a == b).to be true
      end
    end

    describe '#previous' do
      it 'returns the previous business day' do
        expect(business_day.previous).to eq('2023-01-03')
      end
    end

    describe '#next' do
      it 'returns the next business day' do
        expect(business_day.next).to eq('2023-01-05')
      end
    end

    describe '#ends_before' do
      subject(:ends_before) { business_day.ends_before }

      context 'when day_zero is a business day that precedes a working day' do
        let(:day_zero) { Date.parse('2023-01-05') }

        it 'returns the following business day' do
          expect(ends_before).to eq(Date.parse('2023-01-06'))
        end
      end

      context 'when day_zero is a Sunday' do
        let(:day_zero) { Date.parse('2023-01-01') }

        it 'returns the following business day' do
          expect(ends_before).to eq(Date.parse('2023-01-04'))
        end
      end

      context 'when day_zero is the Tuesday after a bank holiday' do
        let(:day_zero) { Date.parse('2023-01-03') }

        it 'returns the following business day' do
          expect(ends_before).to eq(Date.parse('2023-01-04'))
        end
      end
    end
  end

  describe '.list_backwards' do
    subject(:list_backwards) { described_class.list_backwards }

    let(:day_zero) { Time.current }

    describe 'by default' do
      it 'returns a array of the current and previous nine business days' do
        expect(list_backwards.size).to be(10)
        expect(list_backwards.first).to eq(described_class.new.date)
      end

      it 'each item in the array is one business day older than the previous' do
        expect(list_backwards.map(&:age_in_business_days)).to eq (0..9).to_a
      end
    end
  end
end

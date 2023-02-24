require 'rails_helper'

# Required logic for counting in business days.
# Example given for a week with a bank holiday Monday, viewed on Wednesday.
#
# event_date    | 29/12 | 30/12 | 31/01 | 1/1 | 2/1 | 3/1 | 4/1 |
#               |  thu  |  fri  |  sat  | sun | mon | tue | wed |
# age_in_days   |   3   |   2   |   1   |  1  |  1  |  1  |  0  |
# starts_on     |  thu  |  fri  |  sat  | sat | sat | sat | wed |
# ends_before   |  fri  |  sat  |  wed  | wed | wed | wed | nil |

RSpec.describe BusinessDay do
  let(:day_zero) { Date.parse('2023-01-04') }
  let(:age_in_business_days) { 2 }

  describe '.new' do
    subject(:business_day) do
      described_class.new(age_in_business_days:, day_zero:)
    end

    it 'initializes a BusinessDay "age_in_business_days" before "day_zero"' do
      expect(business_day.date).to eq(Date.parse('2022-12-30'))
    end

    describe '#date' do
      context 'when "age_in_business_days" is twenty' do
        let(:age_in_business_days) { 20 }

        it 'returns the date of the twentieth business day from day zero' do
          expect(business_day.date).to eq(Date.parse('2022-12-02'))
        end
      end

      context 'when "age_in_business_days" is 0' do
        let(:age_in_business_days) { 0 }

        it 'returns day_zero' do
          expect(business_day.date).to eq(day_zero)
        end
      end

      context 'when "age_in_business_days" is zero and "day_zero" is not a business day' do
        let(:age_in_business_days) { 0 }
        let(:day_zero) { Date.parse('2023-01-01') }

        it "returns the next business day's date" do
          expect(business_day.date).not_to eq(day_zero)
          expect(business_day.date).to eq(Date.parse('2023-01-03'))
        end
      end
    end

    describe '#period_starts_on' do
      context 'when the previous day is a business day' do
        let(:age_in_business_days) { 2 }

        it 'returns the date' do
          expect(business_day.period_starts_on).to eq(business_day.date)
        end
      end

      context 'when the previous day is a non-business day' do
        let(:age_in_business_days) { 1 }

        it 'returns the date of the first non-business day after the prevous business day' do
          expect(business_day.period_starts_on).not_to eq(business_day.date)
          expect(business_day.period_starts_on).to eq(Date.parse('2022-12-31'))
        end
      end
    end

    describe '#period_ends_before' do
      it 'the first date after the last day in the period' do
        expect(business_day.period_ends_before).to eq(business_day.date.tomorrow)
      end
    end
  end
end

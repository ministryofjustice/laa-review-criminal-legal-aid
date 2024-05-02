require 'rails_helper'

RSpec.describe OffenceDatesComponent, type: :component do
  describe '.new' do
    let(:offence) { instance_double(LaaCrimeSchemas::Structs::Offence, dates:) }

    let(:dates) do
      [
        instance_double(
          LaaCrimeSchemas::Structs::Offence::Date,
          date_from: Date.parse('2024-01-01'), date_to: nil
        ),
        instance_double(
          LaaCrimeSchemas::Structs::Offence::Date,
          date_from: Date.parse('2024-01-04'),
          date_to: Date.parse('2024-01-05')
        )
      ]
    end

    before do
      render_inline(described_class.new(offence:))
    end

    it 'renders each date on a separate line' do
      expect(page.all('p').size).to be 2
    end

    it 'shows only the from date when date is not a range' do
      expect(page.first('p').text).to eq '01/01/2024'
    end

    it 'joins dates that are a range' do
      expect(page.all('p')[1].text).to eq '04/01/2024 – 05/01/2024'
    end
  end
end

require 'rails_helper'

RSpec.describe DateStampContextPresenter do
  subject(:date_stamp_context_presenter) { described_class.new(date_stamp_context) }

  let(:date_stamp_context) { DateStampContext.new(crime_application) }
  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:crime_application) { CrimeApplication.new(attributes) }

  describe '#new' do
    it 'delegates to date_stamp_context' do # rubocop:disable RSpec/MultipleExpectations
      expect(date_stamp_context_presenter.first_name).to eq 'Kitten'
      expect(date_stamp_context_presenter.last_name).to eq 'Pounder'
      expect(date_stamp_context_presenter.date_of_birth.to_date).to eq Date.new(2001, 6, 9)
      expect(date_stamp_context_presenter.date_stamp.to_date).to eq Date.new(2022, 10, 24)
      expect(date_stamp_context_presenter.created_at.to_date).to eq Date.new(2022, 10, 24)
    end
  end

  describe '#show?' do
    subject { described_class.new(date_stamp_context).show? }

    context 'with unchanged applicant details' do
      let(:attributes) do
        super().deep_merge(
          'client_details' => {
            'applicant' => {
              'date_stamp' => Date.new(2022, 10, 24).to_s,
              'first_name' => 'Kitten',
              'last_name' => 'Pounder'
            }
          }
        )
      end

      it { is_expected.to be false }
    end

    context 'with changed applicant details' do
      context 'with changed first name' do
        let(:attributes) do
          super().deep_merge(
            'client_details' => { 'applicant' => { 'first_name' => 'Kittens' } }
          )
        end

        it { is_expected.to be true }
      end

      context 'with changed last name' do
        let(:attributes) do
          super().deep_merge(
            'client_details' => { 'applicant' => { 'last_name' => 'Pointer' } }
          )
        end

        it { is_expected.to be true }
      end

      context 'with changed date of birth' do
        let(:attributes) do
          super().deep_merge(
            'client_details' => { 'applicant' => { 'date_of_birth' => Date.new(1990, 1, 1).to_s } }
          )
        end

        it { is_expected.to be true }
      end
    end

    context 'with missing date stamp context' do
      let(:attributes) do
        attrs = super()
        attrs['date_stamp_context'] = nil
        attrs
      end

      it { is_expected.to be false }
    end

    context 'with corrupted date stamp context' do
      let(:attributes) do
        attrs = super()

        # Missing last_name, date_of_birth, etc
        attrs['date_stamp_context'] = {
          'date_stamp' => Date.new(2022, 10, 24).to_s,
          'first_name' => 'Kitten',
        }

        attrs
      end

      it { is_expected.to be true }
    end
  end
end

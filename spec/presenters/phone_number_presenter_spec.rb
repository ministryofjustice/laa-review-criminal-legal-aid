require 'rails_helper'

RSpec.describe PhoneNumberPresenter do
  subject(:phone_number_presenter) { described_class.new(crime_application) }

  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:crime_application) { CrimeApplication.new(attributes) }

  describe '#for_applicant' do
    subject(:for_applicant) { phone_number_presenter.for_applicant }

    it { is_expected.to eq '07771 231 231' }

    context 'with input that has +44 and no 0' do
      before do
        attributes['client_details']['applicant']['telephone_number'] = '+447123123123'
      end

      it { is_expected.to eq '+44 7123 123 123' }
    end

    context 'with input that has +44 and 0' do
      before do
        attributes['client_details']['applicant']['telephone_number'] = '+4407123456456'
      end

      it { is_expected.to eq '+44 07123 456 456' }
    end

    context 'with input that has +44 and 0 with parentheses' do
      before do
        attributes['client_details']['applicant']['telephone_number'] = '+44(0)7123789789'
      end

      it { is_expected.to eq '+44 (0) 7123 789 789' }
    end
  end
end

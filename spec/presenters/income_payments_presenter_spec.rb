require 'rails_helper'

RSpec.describe IncomePaymentsPresenter do
  subject(:payments_presenter) { described_class.new(crime_application.means_details.income_details.income_payments) }

  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:crime_application) { CrimeApplication.new(attributes) }

  describe '#formatted_income_payments' do
    subject(:formatted_income_payments) { payments_presenter.formatted_income_payments }

    # rubocop:disable RSpec/ExampleLength
    it {
      expect(formatted_income_payments).to include({ 'private_pension' => nil,
                                                     'state_pension' => nil,
                                                     'maintenance' => nil,
                                                     'interest_investment' => nil,
                                                     'student_loan_grant' => nil,
                                                     'board_from_family' =>
                                                       be_a(LaaCrimeSchemas::Structs::IncomeDetails::IncomePayment),
                                                     'rent' => nil,
                                                     'financial_support_with_access' => nil,
                                                     'from_friends_relatives' => nil,
                                                     'other' =>
                                                       be_a(LaaCrimeSchemas::Structs::IncomeDetails::IncomePayment) })
    }
    # rubocop:enable RSpec/ExampleLength

    context 'with empty income payments' do
      before do
        attributes['means_details']['income_details']['income_payments'] = []
      end

      it { expect(formatted_income_payments).to eq({}) }
    end
  end
end

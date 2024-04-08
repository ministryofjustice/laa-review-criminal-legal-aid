require 'rails_helper'

RSpec.describe OutgoingPaymentsPresenter do
  subject(:payments_presenter) { described_class.new(crime_application.means_details.outgoings_details.outgoings) }

  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:crime_application) { CrimeApplication.new(attributes) }

  describe '#formatted_outgoing_payments' do
    subject(:formatted_outgoing_payments) { payments_presenter.formatted_outgoing_payments }

    # rubocop:disable Layout/LineLength
    it {
      expect(formatted_outgoing_payments).to include({ 'childcare' => be_a(LaaCrimeSchemas::Structs::OutgoingsDetails::Outgoing),
                                                     'maintenance' => nil,
                                                     'legal_aid_contribution' => be_a(LaaCrimeSchemas::Structs::OutgoingsDetails::Outgoing) })
    }
    # rubocop:enable Layout/LineLength

    context 'with empty outgoing payments' do
      before do
        attributes['means_details']['outgoings_details']['outgoings'] = []
      end

      it { expect(formatted_outgoing_payments).to eq({}) }
    end
  end
end

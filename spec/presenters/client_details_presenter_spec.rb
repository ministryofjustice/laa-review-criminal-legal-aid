require 'rails_helper'

RSpec.describe ClientDetailsPresenter do
  subject(:client_details_presenter) { described_class.new(client_details) }

  let(:client_details) { crime_application[:client_details] }
  let(:attributes) { JSON.parse(LaaCrimeSchemas.fixture(1.0).read) }
  let(:crime_application) { CrimeApplication.new(attributes) }

  describe '#client_or_partner_passported' do
    context 'when the client has a benefit type' do
      let(:attributes) do
        super().deep_merge(
          'client_details' => {
            'applicant' => {
              'benefit_type' => 'universal_credit'
            }
          }
        )
      end

      it 'returns `Yes`' do
        expect(client_details_presenter.client_or_partner_passported).to eq('Yes')
      end
    end

    context 'when the partner has a benefit type' do
      let(:attributes) do
        super().deep_merge(
          'client_details' => {
            'applicant' => {
              'benefit_type' => 'none'
            },
            'partner' => {
              'benefit_type' => 'universal_credit'
            }
          }
        )
      end

      it 'returns `Yes - partner`' do
        expect(client_details_presenter.client_or_partner_passported).to eq('Yes - partner')
      end
    end

    context 'when neither the client nor the partner has a benefit type' do
      let(:attributes) do
        super().deep_merge(
          'client_details' => {
            'applicant' => {
              'benefit_type' => 'none'
            },
            'partner' => {
              'benefit_type' => 'none'
            }
          }
        )
      end

      it 'returns `No`' do
        expect(client_details_presenter.client_or_partner_passported).to eq('No')
      end
    end
  end
end

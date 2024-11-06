require 'rails_helper'

RSpec.describe Decisions::SendToProviderForm do
  subject(:form_object) { described_class.new(application_id:) }

  let(:application_id) { SecureRandom.uuid }
  let(:user_id) { SecureRandom.uuid }
  let(:send_to_provider) do
    form_object.send_to_provider!(params.with_indifferent_access, user_id)
  end

  describe 'when the next step is "send_to_provider"' do
    let(:params) { { next_step: 'send_to_provider' } }

    context 'when the decisions are complete' do
      before do
        allow(Reviewing::Complete).to receive(:call)
        send_to_provider
      end

      it 'sends the decision to the provider' do
        expect(Reviewing::Complete).to have_received(:call).with(
          application_id:, user_id:
        )
      end
    end

    context 'when decision are incomplete' do
      before do
        allow(Reviewing::Complete).to receive(:call).and_raise(Reviewing::IncompleteDecisions)
      end

      it 'adds the error to the form object and re-raises' do
        expect { send_to_provider }.to raise_error(Reviewing::IncompleteDecisions)
        expect(form_object.errors.full_messages_for(:base).first).to eq 'Complete decision details first'
      end
    end
  end

  describe 'validations' do
    subject(:valid?) { form_object.valid? }

    before { form_object.next_step = next_step }

    context 'when next_step "add_another"' do
      let(:next_step) { 'add_another' }

      it { is_expected.to be true }
    end

    context 'when next_step is "send_to_provider"' do
      let(:next_step) { 'send_to_provider' }

      it { is_expected.to be true }
    end

    context 'when next_step is nil' do
      let(:next_step) { nil }

      it { is_expected.to be false }
    end

    context 'when next_step is "something_else"' do
      let(:next_step) { 'something_else' }

      it { is_expected.to be false }
    end
  end
end

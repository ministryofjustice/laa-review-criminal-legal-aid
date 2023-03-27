RSpec.shared_examples 'a reauthable model' do
  let(:reauthable) { described_class.new(last_auth_at:) }
  let(:last_auth_at) { nil }

  let(:reauthenticate_in) do
    Rails.configuration.x.auth.reauthenticate_in
  end

  describe 'auth_expired?' do
    subject(:auth_expired?) { reauthable.auth_expired? }

    context 'when last_auth_at is nil' do
      it { is_expected.to be false }
    end

    context 'when last_auth_at more recent than the reauthenticate limit' do
      let(:last_auth_at) { (reauthenticate_in - 1).ago }

      it { is_expected.to be false }
    end

    context 'when outside the reauthenticate limit' do
      let(:last_auth_at) { (reauthenticate_in + 1).ago }

      it { is_expected.to be true }
    end

    context 'when reauthenticate_in is not configured' do
      before do
        allow(Rails.configuration.x.auth).to receive(:reauthenticate_in).and_return(nil)
      end

      let(:last_auth_at) { 1.year.ago }

      it { is_expected.to be false }
    end
  end
end

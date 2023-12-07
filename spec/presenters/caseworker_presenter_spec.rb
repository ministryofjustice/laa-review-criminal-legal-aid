require 'rails_helper'

RSpec.describe CaseworkerPresenter do
  subject(:caseworker_presenter) { described_class.new(user) }

  let(:user) { User.create(email: 'Zoe.Example@example.com') }

  describe '#formatted_user_competencies' do
    subject(:formatted_user_competencies) { caseworker_presenter.formatted_user_competencies }

    it { is_expected.to eq 'No competencies' }

    context 'with competencies' do
      before do
        allow(Allocating).to receive(:user_competencies).with(user.id).and_return(['extradition'])
      end

      it { is_expected.to eq 'Extradition' }
    end
  end
end

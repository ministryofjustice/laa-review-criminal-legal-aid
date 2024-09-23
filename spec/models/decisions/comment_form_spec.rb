require 'rails_helper'

RSpec.describe Decisions::CommentForm do
  subject(:form_object) do
    described_class.new(
      comment: comment,
      comment_required: comment_required,
      application_id: 'aid',
      decision_id: 'did'
    )
  end

  let(:comment) { 'Old comment' }
  let(:comment_required) { true }

  describe '#update_with_user!' do
    subject(:update_with_user) do
      form_object.update_with_user!(params, 'uid')
    end

    before do
      allow(Deciding::SetComment).to receive(:call)

      update_with_user
    end

    context 'when comment is no longer required' do
      let(:params) { { comment_required: false, comment: 'New comment' } }

      it 'sets the comment as blank' do
        expect(Deciding::SetComment).to have_received(:call).with(
          application_id: 'aid', decision_id: 'did',
          comment: '', comment_required: false, user_id: 'uid'
        )
      end
    end

    context 'when required comment changes' do
      let(:params) { { comment_required: true, comment: 'New comment' } }

      it 'sets the new comment' do
        expect(Deciding::SetComment).to have_received(:call).with(
          application_id: 'aid', decision_id: 'did',
          comment: 'New comment', comment_required: true, user_id: 'uid'
        )
      end
    end
  end

  describe 'validations' do
    subject(:valid?) { form_object.valid? }

    context 'when comment_required is true' do
      let(:comment_required) { true }

      context 'when comment is present' do
        let(:comment) { 'Caseworker comments' }

        it { is_expected.to be true }
      end

      context 'when comment is absent' do
        let(:comment) { nil }

        it { is_expected.to be false }
      end
    end

    context 'when comment_required is false' do
      let(:comment_required) { false }
      let(:comment) { nil }

      it { is_expected.to be true }
    end

    context 'when comment_required is nil' do
      let(:comment_required) { nil }
      let(:comment) { 'Some comment' }

      it { is_expected.to be false }
    end
  end

  describe '.build' do
    subject(:form) { described_class.build(decision) }

    let(:decision) do
      instance_double(Deciding::Decision, comment: comment, application_id: 'a123', decision_id: 'b456')
    end

    context 'when the decision has a comment' do
      let(:comment) { 'Existing comments' }

      it 'returns a form object with comment_required set to true' do
        expect(form.comment).to eq 'Existing comments'
        expect(form.comment_required).to be true
      end
    end

    context 'when the decision has no comment' do
      let(:comment) { nil }

      it 'returns a form object with comment_required set to nil' do
        expect(form.comment).to be_nil
        expect(form.comment_required).to be_nil
      end
    end
  end

  describe '#command_class' do
    it 'returns Deciding::SetComment' do
      expect(form_object.send(:command_class)).to eq Deciding::SetComment
    end
  end
end

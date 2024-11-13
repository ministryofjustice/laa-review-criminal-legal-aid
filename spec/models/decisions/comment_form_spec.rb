require 'rails_helper'

RSpec.describe Decisions::CommentForm do
  subject(:form_object) do
    described_class.new(
      comment: comment,
      application:,
      decision_id: 'did'
    )
  end

  let(:application) { instance_double(CrimeApplication, id: 'aid') }

  let(:decision) do
    instance_double(
      Deciding::Decision,
      comment: comment,
      decision_id: 'did',
    )
  end


  let(:comment) { 'Old comment' }

  describe '#update_with_user!' do
    subject(:update_with_user) do
      form_object.update_with_user!(params.with_indifferent_access, 'uid')
    end

    before do
      allow(Deciding::SetComment).to receive(:call)

      update_with_user
    end

    context 'when comment is no longer required' do
      let(:params) { { comment: 'New comment' } }

      it 'sets the comment as blank' do
        expect(Deciding::SetComment).to have_received(:call).with(
          application_id: 'aid', decision_id: 'did', reference: 123,
          comment: '', user_id: 'uid'
        )
      end
    end

    context 'when required comment changes' do
      let(:params) { { comment: 'New comment' } }

      it 'sets the new comment' do
        expect(Deciding::SetComment).to have_received(:call).with(
          application_id: 'aid', decision_id: 'did', reference: 123,
          comment: 'New comment', user_id: 'uid'
        )
      end
    end
  end

  describe '.build' do
    subject(:form) { described_class.build(application:, decision:) }

    context 'when the decision has a comment' do
      let(:comment) { 'Existing comments' }

      it 'returns a form object with comment set' do
        expect(form.comment).to eq 'Existing comments'
      end
    end

    context 'when the decision has no comment' do
      let(:comment) { nil }

      it 'returns a form object the comment set to nil' do
        expect(form.comment).to be_nil
      end
    end
  end

  describe '#command_class' do
    it 'returns Deciding::SetComment' do
      expect(form_object.send(:command_class)).to eq Deciding::SetComment
    end
  end
end

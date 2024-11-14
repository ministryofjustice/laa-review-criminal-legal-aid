require 'rails_helper'

RSpec.describe ReviewActionComponent, type: :component do
  describe '.new' do
    before do
      render_inline(described_class.new(review_action:, application:))
    end

    let(:application) { '1234' }

    context 'when review_action is :complete' do
      let(:review_action) { :complete }

      describe 'target' do
        subject { page.first('form')['action'] }

        it { is_expected.to eq('/applications/1234/complete') }
      end

      describe 'method' do
        subject { page.first('form')['method'] }

        it { is_expected.to eq('post') }
      end

      describe 'text' do
        subject { page.first('button').text }

        it { is_expected.to eq('Mark as completed') }
      end
    end

    context 'when review_action is :send_back' do
      let(:review_action) { :send_back }

      describe 'target' do
        subject { page.first('a')['href'] }

        it { is_expected.to eq('/applications/1234/return/new') }
      end

      describe 'text' do
        subject { page.first('a').text }

        it { is_expected.to eq('Send back to provider') }
      end
    end

    context 'when review_action is :mark_as_ready' do
      let(:review_action) { :mark_as_ready }

      describe 'target' do
        subject { page.first('form')['action'] }

        it { is_expected.to eq('/applications/1234/ready') }
      end

      describe 'method' do
        subject { page.first("input[name='_method']", visible: false)['value'] }

        it { is_expected.to eq('put') }
      end

      describe 'text' do
        subject { page.first('button').text }

        it { is_expected.to eq('Mark as ready for MAAT') }
      end
    end
  end
end

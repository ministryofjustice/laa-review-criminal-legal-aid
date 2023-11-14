require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#title' do
    let(:title) { helper.content_for(:page_title) }

    before do
      helper.title(value)
    end

    context 'when value blank' do
      let(:value) { '' }

      it { expect(title).to eq('Review criminal legal aid applications - GOV.UK') }
    end

    context 'when value provided' do
      let(:value) { 'Test page' }

      it { expect(title).to eq('Test page - Review criminal legal aid applications - GOV.UK') }
    end
  end

  describe '#fallback_title' do
    before do
      allow(helper).to receive_messages(controller_name: 'my_controller', action_name: 'an_action')
      allow(helper).to receive(:title)
    end

    it 'calls #title with a blank value' do
      helper.fallback_title

      expect(helper).to have_received(:title).with('')
    end
  end

  describe '#app_banner_tag' do
    before do
      allow(ENV).to receive(:fetch).with('ENV_NAME').and_return(env_name)
    end

    context 'when in local environment' do
      let(:env_name) { HostEnv::LOCAL }

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('local'))
        allow(Rails.env).to receive(:local?).and_return(true)
      end

      it { expect(helper.app_banner_tag).to eq('dev') }
    end

    context 'when in staging environment' do
      let(:env_name) { HostEnv::STAGING }

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('staging'))
        allow(Rails.env).to receive(:staging?).and_return(true)
      end

      it { expect(helper.app_banner_tag).to eq('staging') }
    end

    context 'when in prod environment' do
      let(:env_name) { HostEnv::PRODUCTION }

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      it { expect(helper.app_banner_tag).to eq('beta') }
    end
  end

  describe '#present' do
    before do
      stub_const('FooBar', Class.new)
      stub_const('FooBarPresenter', Class.new(BasePresenter))
      allow(FooBarPresenter).to receive(:new).with(foobar)
    end

    let(:foobar) { FooBar.new }

    context 'with given delegator class' do
      it 'instantiate the presenter with the passed object' do
        helper.present(foobar, FooBarPresenter)
        expect(FooBarPresenter).to have_received(:new).with(foobar)
      end
    end

    context 'with inferred delegator class' do
      it 'instantiate the presenter with the passed object inferring the class' do
        helper.present(foobar)
        expect(FooBarPresenter).to have_received(:new).with(foobar)
      end
    end
  end
end

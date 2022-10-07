require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
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
      allow(helper).to receive(:controller_name).and_return('my_controller')
      allow(helper).to receive(:action_name).and_return('an_action')
      allow(helper).to receive(:title)

      # So we can simulate what would happen on production
      allow(
        Rails.application.config
      ).to receive(:consider_all_requests_local).and_return(false)
    end

    it 'calls #title with a blank value' do
      helper.fallback_title

      expect(helper).to have_received(:title).with('')
    end
  end

  describe '#decorate' do
    before do
      stub_const('FooBar', Class.new)
      stub_const('FooBarDecorator', Class.new(BaseDecorator))
      allow(FooBarDecorator).to receive(:new)
    end

    let(:foobar) { FooBar.new }

    context 'when for a specific delegator class' do
      it 'instantiate the decorator with the passed object' do
        helper.decorate(foobar, FooBarDecorator)

        expect(FooBarDecorator).to have_received(:new).with(foobar)
      end
    end

    context 'when using the object to infer the delegator class' do
      it 'instantiate the decorator with the passed object inferring the class' do
        helper.decorate(foobar)

        expect(FooBarDecorator).to have_received(:new).with(foobar)
      end
    end
  end

  describe '#present' do
    before do
      stub_const('FooBar', Class.new)
      stub_const('FooBarPresenter', Class.new(BasePresenter))
      allow(FooBarPresenter).to receive(:new)
    end

    let(:foobar) { FooBar.new }

    context 'with a specific delegator class' do
      it 'instantiate the presenter with the passed object' do
        helper.present(foobar, FooBarPresenter)

        expect(FooBarPresenter).to have_received(:new).with(foobar)
      end
    end

    context 'when using the object to infer the delegator class' do
      it 'instantiate the presenter with the passed object inferring the class' do
        helper.present(foobar)

        expect(FooBarPresenter).to have_received(:new).with(foobar)
      end
    end
  end
end

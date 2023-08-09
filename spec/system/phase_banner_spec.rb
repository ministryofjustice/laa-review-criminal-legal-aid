require 'rails_helper'

RSpec.describe 'Phase banner' do
  before do
    visit '/'
  end

  describe 'custom phase banner styling' do
    # NOTE: Prod uses default styling so only non prod envs are tested
    before do
      allow(ENV).to receive(:fetch).with('ENV_NAME').and_return(env_name)
    end

    context 'when in local environment' do
      let(:env_name) { HostEnv::LOCAL }

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('local'))
        allow(Rails.env).to receive(:local?).and_return(true)
        visit '/'
      end

      it 'has env specific styling applied' do
        expect(page).to have_css('.app-banner-local')
      end
    end

    context 'when in staging environment' do
      let(:env_name) { HostEnv::STAGING }

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('staging'))
        allow(Rails.env).to receive(:staging?).and_return(true)
        visit '/'
      end

      it 'has env specific styling applied' do
        expect(page).to have_css('.app-banner-staging')
      end
    end
  end
end

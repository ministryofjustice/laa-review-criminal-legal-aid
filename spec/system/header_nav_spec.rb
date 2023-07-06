require 'rails_helper'

RSpec.describe 'Header navigation' do
  before do
    visit '/'
  end

  it 'shows name of current user' do
    current_user = page.first('.govuk-header__navigation-item').text
    expect(current_user).to eq('Joe EXAMPLE')
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

  context 'when user does not have access to manage other users' do
    before do
      visit '/'
    end

    it 'does not have a link to manage users' do
      header = page.first('.govuk-header__navigation-list').text
      expect(header).not_to include('Manage users')
    end
  end

  context 'when a user has access to manage other users' do
    before do
      User.update(current_user_id, can_manage_others: true)
      visit admin_manage_users_root_path
    end

    it 'they are redirected to the admin manage users route by default' do
      expect { click_link('Manage users') }.not_to change { page.first('.govuk-heading-xl').text }.from('Manage users')
    end

    context 'when user managers are allowed to access the service' do
      before do
        # Override allow_user_managers_service_access as per staging
        allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
        visit '/'
      end

      it 'shows the "Manage users" link and can follow it' do
        expect { click_link('Manage users') }.to change {
                                                   page.first('.govuk-heading-xl').text
                                                 }.from('Your list').to('Manage users')
      end
    end
  end
end

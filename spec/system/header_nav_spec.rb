require 'rails_helper'

RSpec.describe 'Header navigation' do
  before do
    visit '/'
  end

  it 'shows name of current user' do
    current_user = page.first('.govuk-header__navigation-item').text
    expect(current_user).to eq('Joe EXAMPLE')
  end

  context 'when user does not have access to manage other users' do
    it 'does not have a link to manage users' do
      header = page.first('.govuk-header__navigation-list').text
      expect(header).not_to include('Manage users')
    end

    it 'does not have a link to performance tracking' do
      header = page.first('.govuk-header__navigation-list').text
      expect(header).not_to include('Performance tracking')
    end

    context 'when logged in as a supervisor' do
      let(:current_user_role) { UserRole::SUPERVISOR }

      it 'shows the "Performance tracking" link and can follow it' do
        expect { click_link('Performance tracking') }.to change {
          page.first('.govuk-heading-xl').text
        }.from('Your list').to('Performance tracking')
      end
    end
  end

  context 'when a user has access to manage other users' do
    include_context 'when logged in user is admin'

    it 'they are redirected to the admin manage users route by default' do
      expect { click_link('Manage users') }.not_to change { page.first('.govuk-heading-xl').text }.from('Manage users')
    end

    it 'does not have a link to performance tracking' do
      header = page.first('.govuk-header__navigation-list').text
      expect(header).not_to include('Performance tracking')
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

      it 'shows the "Performance tracking" link and it can be followed' do
        expect { click_link('Performance tracking') }.to change {
          page.first('.govuk-heading-xl').text
        }.from('Your list').to('Performance tracking')
      end
    end
  end
end

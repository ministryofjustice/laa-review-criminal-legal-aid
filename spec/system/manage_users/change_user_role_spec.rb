require 'rails_helper'

RSpec.describe 'Change user role' do
  include_context 'when logged in user is admin'
  include_context 'with an existing user'
  include_context 'with a stubbed mailer'

  let(:notify_mailer_method) { :role_changed_email }

  describe 'when user is activated' do
    before do
      User.create!(can_manage_others: true, auth_subject_id: SecureRandom.uuid, email: 'test2@eg.com')

      active_user.update(role: 'supervisor')
      visit '/admin/manage_users/active_users'

      within user_row do
        click_on('Change role')
      end
    end

    let(:confirmation_button) do
      find(:xpath, "//button[@type='submit']")
    end

    it 'shows the confirmation page' do
      expect(page).to have_content "Are you sure you want to change Zoe Blogs's role from Supervisor to Caseworker?"
    end

    it 'shows notification' do
      click_on 'Yes, change to Caseworker'

      expect(page).to have_success_notification_banner(
        text: "Zoe Blogs's role has been changed from Supervisor to Caseworker"
      )
    end

    it 'sends notification email to all admin users' do
      admin_emails = [current_user.email, 'test2@eg.com']
      click_on 'Yes, change to Caseworker'

      expect(NotifyMailer).to have_received(:role_changed_email).with(admin_emails, active_user)
      expect(mailer_double).to have_received(:deliver_now)
    end
  end

  describe 'when user is deactivated' do
    before do
      user.update(
        deactivated_at: Time.zone.now
      )
    end

    context 'with UI based flow' do
      before do
        visit '/admin/manage_users/deactivated_users'
      end

      it 'does not show change role action' do
        within user_row do
          expect(page).not_to have_content 'Change role'
          expect(page).to have_content 'Reactivate'
        end
      end
    end

    context 'with URL based flow' do
      before do
        visit "/admin/manage_users/change_roles/#{user.id}/edit"
      end

      it 'is not found' do
        expect(page).to have_title 'Page not found'
      end
    end
  end

  describe 'when user is dormant' do
    before do
      user.update(
        first_auth_at: 200.days.ago,
        last_auth_at: 100.days.ago
      )
    end

    context 'with UI based flow' do
      before do
        visit '/admin/manage_users/active_users'
      end

      it 'does not show change role action' do
        within user_row do
          expect(page).not_to have_content 'Change role'
          expect(page).to have_content 'Revive'
        end
      end
    end

    context 'with URL based flow' do
      before do
        visit "/admin/manage_users/change_roles/#{user.id}/edit"
      end

      it 'shows warning' do
        expect(page).to have_notification_banner(
          text: "Unable to change #{user.name}'s role",
          details: []
        )
      end
    end
  end

  describe 'when feature is disabled' do
    before do
      allow(FeatureFlags).to receive(:basic_user_roles) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }
      active_user

      visit '/admin/manage_users/active_users'
    end

    it 'does not show Change role action' do
      within user_row do
        expect(page).not_to have_content 'Change role'
      end
    end

    it 'denies role change if forced via URL' do
      visit "/admin/manage_users/change_roles/#{user.id}/edit"

      expect(page).to have_notification_banner(
        text: "Unable to change #{user.name}'s role",
        details: []
      )
    end
  end

  describe 'when admin manipulates the URL' do
    context 'with their own user id' do
      before do
        visit "/admin/manage_users/change_roles/#{current_user.id}/edit"
        click_on 'Yes, change to Supervisor'
      end

      it 'shows warning' do
        expect(page).to have_notification_banner(
          text: "Unable to change #{current_user.name}'s role"
        )
      end
    end
  end
end

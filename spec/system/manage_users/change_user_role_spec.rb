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
      visit '/manage-users/active-users'

      click_on('Zoe Blogs')
      click_on('Change role')
    end

    it 'shows the confirmation page' do
      expect(page).to have_content "Are you sure you want to change Zoe Blogs's role from Supervisor?"
    end

    it 'shows other available roles' do
      expect(page).to have_unchecked_field('Caseworker')
      expect(page).to have_unchecked_field('Data analyst')
    end

    it 'shows notification' do
      choose 'Caseworker'
      click_on 'Save new role'

      expect(page).to have_success_notification_banner(
        text: "Zoe Blogs's role has been changed from Supervisor to Caseworker"
      )
    end

    it 'sends notification email to all admin users' do
      admin_emails = [current_user.email, 'test2@eg.com']
      choose 'Caseworker'
      click_on 'Save new role'

      expect(NotifyMailer).to have_received(:role_changed_email).with(admin_emails, active_user)
      expect(mailer_double).to have_received(:deliver_later)
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
        visit '/manage-users/deactivated-users'
        click_on('Zoe Blogs')
      end

      it 'does not show change role action' do
        expect(page).to have_no_content 'Change role'
        expect(page).to have_content 'Reactivate'
      end
    end

    context 'with URL based flow' do
      before do
        visit "/manage-users/change-roles/#{user.id}/edit"
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
        visit '/manage-users/active-users'
        click_on('Zoe Blogs')
      end

      it 'does not show change role action' do
        expect(page).to have_no_content 'Change role'
        expect(page).to have_content 'Revive'
      end
    end

    context 'with URL based flow' do
      before do
        visit "/manage-users/change-roles/#{user.id}/edit"
      end

      it 'shows warning' do
        expect(page).to have_notification_banner(
          text: "Unable to change #{user.name}'s role",
          details: []
        )
      end
    end
  end

  describe 'when admin manipulates the HTTP client' do
    context 'with their own user id' do
      before do
        visit "/manage-users/change-roles/#{current_user.id}/edit"
        choose 'Data analyst'
        click_on 'Save new role'
      end

      it 'shows warning' do
        expect(page).to have_notification_banner(
          text: "Unable to change #{current_user.name}'s role"
        )
      end
    end
  end

  describe 'when no new role is selected' do
    before do
      active_user
      visit '/manage-users/active-users'
      click_on('Zoe Blogs')
      click_on('Change role')
      click_on('Save new role')
    end

    it 'shows warning message' do
      expect(page).to have_notification_banner(
        text: "#{user.name}'s role was not changed",
        details: []
      )
    end
  end
end

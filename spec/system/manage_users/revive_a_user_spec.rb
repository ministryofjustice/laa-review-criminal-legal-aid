require 'rails_helper'

RSpec.describe 'Revive a user' do
  let(:mail_double) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  let(:dormant_user) do
    User.create!(
      can_manage_others: false,
      auth_subject_id: SecureRandom.uuid,
      last_auth_at: 100.days.ago,
      first_auth_at: 100.days.ago,
      first_name: 'Taylor',
      last_name: 'Quick',
      email: 'taylor.quick@example.com'
    )
  end

  let(:current_user_can_manage_others) { true } # System spec admin user
  let(:actions) { page.first('ul.govuk-summary-list__actions-list') }
  let(:first_log_entry) { page.first('table tbody tr').all('td') }

  before do
    allow(NotifyMailer).to receive(:revive_account_email) { mail_double }
    dormant_user
  end

  describe 'when admin revives dormant user' do
    before do
      visit '/manage_users/active_users'
      click_on('Taylor Quick')
      click_on('Revive')
    end

    it 'shows notification' do
      expect(page).to have_success_notification_banner(
        text: 'Taylor Quick has been notified to revive their account'
      )
    end

    it 'shows Awaiting Revival status' do
      click_on('Taylor Quick')

      within actions do
        expect(page).to have_content 'Awaiting revival'
      end
    end

    it 'sends notification email to dormant user' do
      expect(NotifyMailer).to have_received(:revive_account_email).with('taylor.quick@example.com')
    end

    it 'gives dormant user 48 hours to log in' do
      expect(dormant_user.reload.revive_until.to_date.to_s).to eq 48.hours.from_now.to_date.to_s
    end

    it 'shows an entry in user history' do
      click_on('Taylor Quick')
      expect(first_log_entry[1]).to have_content 'Account revival'
    end
  end

  describe 'when dormant user has been notified' do
    before do
      dormant_user.update!(revive_until: 48.hours.from_now) # Mimic Admin clicking 'revive'
      login_as(dormant_user) # The dormant user logs in
    end

    context 'when dormant user signs in' do
      it 'revives the user account' do
        within('header') do |header|
          expect(header).to have_content 'Taylor Quick'
        end

        expect(dormant_user.reload.dormant?).to be false
      end
    end

    context 'when the admin user views manage users dashboard' do
      before do
        login_as(current_user) # The admin user logs in
        visit '/manage_users/active_users'
        click_on('Taylor Quick')
      end

      it 'shows updated user history' do
        expect(first_log_entry[1]).to have_content 'Account revived'
      end

      it 'no longer shows user as `Awaiting revival`' do
        within actions do
          expect(page).to have_content 'Deactivate' # Back to normal actions
        end
      end
    end
  end

  describe 'when user is not dormant' do
    let(:normal_user) do
      User.create!(
        auth_subject_id: SecureRandom.uuid,
        last_auth_at: 4.days.ago,
        first_auth_at: 4.days.ago,
        first_name: 'Dave',
        email: 'normal_user@example.com'
      )
    end

    it 'denies revival attempt' do
      visit edit_manage_users_revive_user_path(id: normal_user.id)

      expect(page).to have_notification_banner(
        text: 'Dave does not have a dormant account'
      )
    end
  end

  describe 'when dormant user misses revive deadline' do
    before do
      visit '/manage_users/active_users' # As admin
      click_on('Taylor Quick')
      click_on('Revive')

      dormant_user.update!(revive_until: 4.days.ago) # Force premature expiration
    end

    it 'shows dormant user error on sign in' do
      login_as(dormant_user)

      expect(page).to have_notification_banner(
        text: 'You cannot access this service',
        details: [
          'This is because you have not signed in to the service for more than 90 days.',
          "Contact #{Rails.application.config.x.admin.onboarding_email} to reactivate your account."
        ]
      )
    end

    it 'allows admin to begin revive process again' do
      visit '/manage_users/active_users'
      click_on('Taylor Quick')

      within actions do
        expect(page).to have_content 'Revive'
      end
    end
  end

  describe 'when dormant user is deactivated' do
    before do
      User.create!(
        auth_subject_id: SecureRandom.uuid,
        last_auth_at: 100.days.ago,
        first_auth_at: nil,
        deactivated_at: Time.zone.now,
        first_name: 'Will',
        last_name: 'I Am',
        email: 'will.i.am.inactive@example.com'
      )
    end

    it 'does not allow revival process' do
      visit '/manage_users/deactivated_users'
      click_on('Will I Am')

      within actions do
        expect(page).to have_no_text('Revive')
      end
    end
  end

  def login_as(user)
    visit '/sign_out'
    click_button 'Start now'
    select user.email
    click_button 'Sign in'
  end
end

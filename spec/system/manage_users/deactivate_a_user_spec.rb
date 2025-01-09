require 'rails_helper'

RSpec.describe 'Deactivate a user from the manage users dashboard' do
  include_context 'when logged in user is admin'
  include_context 'with an existing user'
  let(:confirm_path) { new_manage_users_deactivated_user_path }

  def do_deactivate_journey
    active_user
    visit '/'
    visit manage_users_root_path
    click_on('Zoe Blogs')
    click_on('Deactivate')
  end

  describe 'with at least 2 other active admins' do
    before do
      User.create!(can_manage_others: true, auth_subject_id: SecureRandom.uuid, email: 'test2@eg.com')
      do_deactivate_journey
    end

    it 'has 2 other active admins' do
      expect(User.admins.size).to eq 2
      expect(active_user.can_manage_others).to be false
    end

    context 'when clicking "deactivate" shows warning page' do
      it 'prompts to confirm the action' do
        expect(page).to have_content(
          'Are you sure you want to deactivate Zoe Blogs?'
        )
      end

      it 'warns about the impact of deactivating' do
        within('.govuk-warning-text') do
          expect(page).to have_content(
            'This will mean Zoe Blogs can no longer access this service.'
          )
        end
      end
    end

    context 'when clicking "Yes, deactivate"' do
      it 'redirects to the manage user list' do
        expect { click_on('Yes, deactivate') }.to(
          change { page.current_path }.from(confirm_path).to(manage_users_root_path)
        )
      end

      it 'shows the success notice' do
        click_on('Yes, deactivate')

        within('.govuk-notification-banner--success') do
          expect(page).to have_content('Zoe Blogs has been deactivated')
        end
      end

      it 'deactivates the user' do
        expect { click_on('Yes, deactivate') }.to(
          change { active_user.reload.deactivated? }.from(false).to(true)
        )
      end
    end

    describe 'logging the deactivation in the user\'s account history' do
      before do
        click_on('Yes, deactivate')
        visit manage_users_deactivated_users_path
        click_link 'Zoe Blogs'
      end

      let(:cells) { page.first('table tbody tr').all('td') }

      it 'describes the event' do
        expect(cells[1]).to have_content 'Account deactivated'
      end

      it 'includes the manager\'s name' do
        expect(cells.last).to have_content 'Joe EXAMPLE'
      end
    end

    context 'when clicking "No, do not deactivate"' do
      it 'redirects to the manage user list' do
        expect { click_on('No, do not deactivate') }.to(
          change { page.current_path }.from(confirm_path).to(manage_users_root_path)
        )
      end

      it 'does not deactivate the user' do
        expect { click_on('No, do not deactivate') }.not_to(
          change { active_user.reload.deactivated? }.from(false)
        )
      end
    end
  end

  describe 'with only 2 active admins' do
    let(:user_can_manage_others) { true }

    before do
      User.create!(can_manage_others: true, deactivated_at: Time.zone.now, email: 'test3@eg.com') # Inactive

      do_deactivate_journey
      click_on('Yes, deactivate')
    end

    it 'has 2 active admins' do
      expect(User.admins.size).to eq 2
    end

    it 'shows error message on manage users page' do
      within('.govuk-notification-banner__heading') do
        expect(page).to have_content(
          'Unable to deactivate user. There must be at least two users who can manage others'
        )
      end
    end
  end
end

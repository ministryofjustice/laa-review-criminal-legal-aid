require 'rails_helper'

RSpec.describe 'Change caseworker competencies' do
  let(:current_user_role) { UserRole::SUPERVISOR }

  before do
    User.create!(
      email: 'test@example.com',
      first_name: 'Iain',
      last_name: 'Testing',
      auth_subject_id: SecureRandom.uuid
    )
    visit manage_competencies_root_path
    find('tr', text: /Iain/).click_on('No competencies')
  end

  describe 'when viewing the form' do
    it 'shows other available competencies' do # rubocop:disable RSpec/MultipleExpectations
      expect(page).to have_unchecked_field('Extradition')
      expect(page).to have_unchecked_field('CAT 2')
      expect(page).to have_unchecked_field('CAT 1')
      expect(page).to have_unchecked_field('Initial')
      expect(page).to have_unchecked_field('Post submission evidence')
    end
  end

  describe "when there is an update to a caseworker's competencies" do
    before do
      check 'Extradition'
      check 'Initial'
      click_on 'Save'
    end

    it 'displays selected competency' do
      first_data_row = page.first('.govuk-table tbody tr').text
      expect(first_data_row).to eq('Iain Testing Extradition, Initial View history')
    end

    it 'form is pre-populated with selected competency' do
      click_on('Extradition')
      expect(page).to have_checked_field('Extradition')
      expect(page).to have_checked_field('Initial')
    end

    it 'displays success message' do
      expect(page).to have_success_notification_banner(
        text: "Iain Testing's competencies saved"
      )
    end
  end

  describe "when there is no update to a caseworker's competencies" do
    before do
      click_on('Save')
    end

    it 'redirects to manage competencies dashboard' do
      expect(page).to have_current_path(manage_competencies_root_path)
    end
  end
end

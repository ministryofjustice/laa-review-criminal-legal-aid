require 'rails_helper'

RSpec.describe 'Change caseworker competencies' do
  let(:current_user_role) { UserRole::SUPERVISOR }

  before do
    User.create!(email: 'test@example.com', first_name: 'Test', last_name: 'Testing',
                 auth_subject_id: SecureRandom.uuid)
    visit manage_competencies_root_path
    click_on('No competencies')
  end

  describe 'when viewing the form' do
    # rubocop:disable RSpec/MultipleExpectations
    it 'shows other available competencies' do
      expect(page).to have_unchecked_field('Extradition')
      expect(page).to have_unchecked_field('National crime team')
      expect(page).to have_unchecked_field('Criminal applications team')
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe "when there is an update to a caseworker's competencies" do
    before do
      check 'Extradition'
      click_on 'Change competencies'
    end

    it 'displays selected competency' do
      first_data_row = page.first('.govuk-table tbody tr').text
      expect(first_data_row).to eq(['Test Testing Extradition History'].join(' '))
    end

    it 'form is pre-populated with selected competency' do
      click_on('Extradition')
      expect(page).to have_checked_field('Extradition')
    end
  end

  describe "when there is no update to a caseworker's competencies" do
    before do
      click_on('Change competencies')
    end

    it 'redirects to manage competencies dashboard' do
      expect(page).to have_current_path(manage_competencies_root_path)
    end
  end
end

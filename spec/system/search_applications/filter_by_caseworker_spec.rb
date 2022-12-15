require 'rails_helper'

RSpec.describe 'Search applications casewoker filter' do
  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:crime_application_id_two) { '1aa4c689-6fb5-47ff-9567-5eee7f8ac2cc' }

  let(:david_brown) do
    User.new(
      id: SecureRandom.uuid,
      first_name: 'David',
      last_name: 'Brown',
      email: 'David.Browneg@justice.gov.uk'
    )
  end

  let(:john_deere) do
    User.new(
      id: SecureRandom.uuid,
      first_name: 'John',
      last_name: 'Deere',
      email: 'John.Deereeg@justice.gov.uk'
    )
  end

  before do
    Assigning::AssignToSelf.new(
      crime_application_id: crime_application_id,
      user: david_brown
    ).call

    visit '/'

    click_on 'Search'
  end

  describe 'by default' do
    before do
      click_button 'Search'
    end

    it 'shows both assinged and unassinged' do
      expect(page).to have_content('2 search results')
    end
  end

  describe 'by a user' do
    before do
      select david_brown.name, from: 'filter-assigned-user-id-field'
      click_button 'Search'
    end

    it 'shows only those assigned to the selected user' do
      expect(page).to have_content('1 search result')
      page.all('.app-dashboard-table tbody tr').map do |row|
        expect(row.text).to match david_brown.name
      end
    end
  end

  describe 'by unassigned' do
    before do
      select 'Unassigned', from: 'filter-assigned-user-id-field'
      click_button 'Search'
    end

    it 'shows only unassigned applications' do
      expect(page).to have_content('1 search result')

      page.all('.app-dashboard-table tbody tr').map do |row|
        expect(row).not_to match david_brown.name
      end
    end
  end

  describe 'All assigned' do
    before do
      Assigning::AssignToSelf.new(
        crime_application_id: crime_application_id_two,
        user: john_deere
      ).call

      select 'All assigned', from: 'filter-assigned-user-id-field'
      click_button 'Search'
    end

    it 'shows all assigned applications' do
      expect(page).to have_content('2 search result')
    end
  end
end

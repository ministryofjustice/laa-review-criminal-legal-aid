require 'rails_helper'

RSpec.describe 'Search applications casewoker filter' do
  let(:crime_application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }

  let(:david_brown) do
    User.new(
      id: SecureRandom.uuid,
      first_name: 'David',
      last_name: 'Brown',
      email: 'David.Browneg@justice.gov.uk',
      roles: ['caseworker']
    )
  end

  before do
    Assigning::AssignToSelf.new(
      crime_application_id: crime_application_id,
      user: david_brown
    ).call

    visit '/'

    click_on 'All open applications'
  end

  describe 'by default' do
    before do
      click_on 'Search'
    end

    it 'shows both assinged and unassinged' do
      expect(page).to have_content('2 search results')
    end
  end

  describe 'by a user' do
    before do
      select david_brown.name, from: 'filter-assigned-user-id-field'
      click_on 'Search'
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
      click_on 'Search'
    end

    it 'shows only unassigned applications' do
      expect(page).to have_content('1 search result')

      page.all('.app-dashboard-table tbody tr').map do |row|
        expect(row).not_to match david_brown.name
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Viewing an application that has been archived' do
  include_context 'with stubbed application'

  before do
    Deleting::ArchiveApplicationEvent.call(
      id: SecureRandom.uuid,
      data: {
        'id' => application_id,
        'reference' => 6_000_001,
        'archived_at' => 1.week.ago.iso8601,
        'application_type' => 'initial'
      }
    )
  end

  describe 'applications history' do
    before do
      visit crime_application_path(application_id)
      click_link 'Application history'
    end

    it 'shows the archived event from the ReferenceHistory stream' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Provider Application deleted by provider')
    end
  end
end

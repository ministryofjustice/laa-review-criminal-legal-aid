require 'rails_helper'

RSpec.describe 'Caseworker report unassigns from self' do
  let(:current_user_role) { UserRole::SUPERVISOR }

  let(:interval) { Types::TemporalInterval['daily'] }
  let(:period) { '2023-01-01' }
  let(:report_type) { Types::TemporalReportType['caseworker_report'] }

  let(:caseworker) do
    User.create(
      first_name: 'Jane',
      last_name: 'Doe',
      auth_oid: SecureRandom.uuid,
      email: 'Jane.Doe@justice.gov.uk'
    )
  end

  let(:assignment_ids) { Array.new(2) { SecureRandom.uuid } }

  before do
    travel_to(Time.zone.local(2023, 1, 1))

    event_store = Rails.configuration.event_store

    assignment_ids.each do |id|
      event_store.publish(Assigning::AssignedToUser.new(data: { to_whom_id: caseworker.id, assignment_id: id }))
      event_store.publish(Assigning::UnassignedFromUser.new(data: { from_whom_id: caseworker.id, assignment_id: id }))
    end

    visit reporting_temporal_report_path(
      interval:, report_type:, period:
    )
  end

  context 'when a caseworker has unassigned applications from themselves' do
    before do
      stub_request(
        :post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches"
      ).and_return(body: {
        pagination: { total_count: 0, total_pages: 1, limit_value: 50 },
        records: []
      }.deep_stringify_keys.to_json)
    end

    it 'displays the unassign count as a clickable link' do
      within('.app-table tbody') do
        row = find('tr', text: 'Jane Doe')
        unassign_detail_cell = row.all('td.colgroup-detail')[2]

        expect(unassign_detail_cell).to have_link('2')
      end
    end

    it 'navigates to the caseworker unassigned applications page', :aggregate_failures do
      within('.app-table tbody') do
        row = find('tr', text: 'Jane Doe')
        unassign_detail_cell = row.all('td.colgroup-detail')[2]

        unassign_detail_cell.click_link('2')
      end

      expect(page).to have_content('Jane Doe')
      expect(page).to have_content('Applications removed from list')
    end
  end

  context 'when a caseworker has zero unassigns' do
    before do
      other_caseworker = User.create(
        first_name: 'John',
        last_name: 'Smith',
        auth_oid: SecureRandom.uuid,
        email: 'John.Smith@justice.gov.uk'
      )

      event_store = Rails.configuration.event_store

      event_store.publish(
        Assigning::AssignedToUser.new(data: { to_whom_id: other_caseworker.id, assignment_id: SecureRandom.uuid })
      )

      visit reporting_temporal_report_path(
        interval:, report_type:, period:
      )
    end

    it 'does not display the zero count as a link' do
      within('.app-table tbody') do
        row = find('tr', text: 'John Smith')
        unassign_detail_cell = row.all('td.colgroup-detail')[2]

        expect(unassign_detail_cell).not_to have_link
        expect(unassign_detail_cell).to have_text('0')
      end
    end
  end
end

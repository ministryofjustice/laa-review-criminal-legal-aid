require 'rails_helper'

RSpec.describe 'Unassigned from self report' do
  include_context 'with stubbed search'

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
  end

  context 'when visiting the unassigned from self report page' do
    before do
      visit reporting_caseworker_temporal_report_path(
        report_type: 'unassigned_from_self_report',
        interval: interval,
        period: period,
        user_id: caseworker.id
      )
    end

    it 'displays the caseworker name' do
      expect(page).to have_content('Jane Doe')
      expect(page).to have_content('Applications removed from list')
    end

    it 'searches the datastore with the unassigned application ids' do
      expect(WebMock).to(have_requested(
        :post, "#{ENV.fetch('DATASTORE_API_ROOT')}/api/v1/searches"
      ).with do |req|
        body = JSON.parse(req.body)
        body.dig('search', 'application_id_in')&.sort == assignment_ids.sort
      end)
    end

    it 'displays search results' do
      expect(page).to have_content('Kit Pound')
    end
  end

  context 'when the caseworker has no unassigned applications' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:other_caseworker) do
      User.create(
        first_name: 'John',
        last_name: 'Smith',
        auth_oid: SecureRandom.uuid,
        email: 'John.Smith@justice.gov.uk'
      )
    end

    let(:stubbed_search_results) { [] }

    before do
      visit reporting_caseworker_temporal_report_path(
        report_type: 'unassigned_from_self_report',
        interval: interval,
        period: period,
        user_id: other_caseworker.id
      )
    end

    it 'shows no results message' do
      expect(page).to have_content('John Smith')
      expect(page).to have_content('No unassigned applications found')
    end
  end
end

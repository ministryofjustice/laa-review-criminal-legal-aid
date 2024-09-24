require 'rails_helper'

RSpec.describe "Viewing a resubmitted application's history" do
  include_context 'with resubmitted application'

  before do
    visit history_crime_application_path(application_id)
  end

  context 'when viewing the resubmitted application\'s history' do
    let(:application_data) { super().deep_merge('parent_id' => parent_id) }

    it 'includes a link to the previous version of the application in the application history' do
      within('tbody.govuk-table__body') do
        expect { click_on('Go to this version') }.to change { page.current_path }
          .from(history_crime_application_path(application_id))
          .to(crime_application_path(parent_id))
      end
    end
  end

  context 'when viewing the superseded application\'s history' do
    before do
      visit(history_crime_application_path(parent_id))
    end

    it 'shows the resubmission event at the top of the application history' do
      first_row = page.first('.app-dashboard-table tbody tr').text
      expect(first_row).to match('Application resubmitted Go to this version')
    end

    it 'the resubmission item includes a link to the resubmitted application' do
      expect { click_on('Go to this version') }.to change { page.current_path }
        .from(history_crime_application_path(parent_id))
        .to(crime_application_path(application_id))
    end
  end
end

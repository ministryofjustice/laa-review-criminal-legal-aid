require 'rails_helper'

RSpec.describe "Viewing a resubmitted application's history" do
  include_context 'with resubmitted application'

  shared_examples 'resubmitted application history' do |link_to_parent|
    context 'when viewing the resubmitted application\'s history' do
      let(:application_data) { super().deep_merge('parent_id' => parent_id) }

      before do
        visit history_crime_application_path(application_id)
      end

      it 'includes a link to the previous version of the application in the application history' do
        within('tbody.govuk-table__body') do
          expect { click_on(link_to_parent) }.to change { page.current_path }
            .from(history_crime_application_path(application_id))
            .to(crime_application_path(parent_id))
        end
      end
    end
  end

  context 'when the reference_history feature flag is disabled' do
    before do
      allow(FeatureFlags).to receive(:reference_history) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }
    end

    it_behaves_like 'resubmitted application history', 'Go to this version'

    context 'when viewing the superseded application\'s history' do
      before do
        visit history_crime_application_path(parent_id)
      end

      it 'shows the resubmission event at the top of the application history' do
        first_row = page.first('.app-dashboard-table tbody tr').text
        expect(first_row).to match('Application resubmitted by provider Go to this version')
      end

      it 'the resubmission item includes a link to the resubmitted application' do
        expect { click_on('Go to this version') }.to change { page.current_path }
          .from(history_crime_application_path(parent_id))
          .to(crime_application_path(application_id))
      end
    end
  end

  context 'when the reference_history feature flag is enabled' do
    before do
      allow(FeatureFlags).to receive(:reference_history) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }
    end

    it_behaves_like 'resubmitted application history', 'View application 1'

    context 'when viewing the superseded application\'s history' do
      before do
        visit history_crime_application_path(parent_id)
      end

      it 'shows events from the ReferenceHistory stream sorted by timestamp' do
        first_row = page.first('.app-dashboard-table tbody tr').text
        expect(first_row).to match('Application resubmitted by provider View application 2')
      end

      it 'the resubmission item includes a link to the resubmitted application' do
        expect { click_on('View application 2') }.to change { page.current_path }
          .from(history_crime_application_path(parent_id))
          .to(crime_application_path(application_id))
      end

      it 'the application history includes a link to the parent application' do
        expect(page).to have_content('Application submitted by provider')
        expect(page).to have_link('View application 1')
      end
    end
  end
end

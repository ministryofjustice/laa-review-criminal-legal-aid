require 'rails_helper'

RSpec.describe 'Reviewing a Non-means application' do
  include_context 'with stubbed application' do
    let(:feature_flag_enabled?) { false }

    let(:application_data) do
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read).merge(
        'is_means_tested' => 'no',
        'work_stream' => 'non_means_tested'
      )
    end

    before do
      allow(FeatureFlags).to receive(:adding_decisions) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: feature_flag_enabled?)
      }

      allow(DatastoreApi::Requests::UpdateApplication).to receive(:new).and_return(
        instance_double(DatastoreApi::Requests::UpdateApplication, call: {})
      )

      visit crime_application_path(application_id)
      click_button 'Assign to your list'
    end

    it 'can be completed by the caseworker' do
      expect(page).to have_button('Send back to provider')
      click_button 'Mark as completed'
      expect(page).to have_content('You marked the application as complete')
    end

    context 'when adding decisions feature flag enabled' do
      let(:feature_flag_enabled?) { true }

      before do
        click_button 'Start'
        choose_answer('What is the interests of justice test result?', 'Passed')
        fill_in('What is the reason for this?', 'Test result reason details')
        fill_in('Enter the name of the caseworker who assessed this', 'Zoe Blogs')
        fill_date('Enter the date of assessment', Date.yesterday)
        save_and_continue
      end

      it 'can be completed by the caseworker' do
      end
    end
  end
end

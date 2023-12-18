require 'rails_helper'

RSpec.describe 'No competencies' do
  include_context 'with an existing application'

  let(:current_user_competencies) { [] }
  let(:view_app_banner_text) do
    'You must be allocated to a work queue to view applications'
  end

  let(:review_app_banner_text) do
    'You must be allocated to the CAT 1 work queue to review this application'
  end

  let(:details) { 'Contact your supervisor to arrange this' }

  before do
    visit '/'

    allow(FeatureFlags).to receive(:work_stream) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }
  end

  context 'when navigating to application pages' do
    it 'displays a notification banner' do
      click_on 'open applications'
      expect(page).to have_notification_banner(text: view_app_banner_text, details: details, success: false)

      click_on 'Closed applications'
      expect(page).to have_notification_banner(text: view_app_banner_text, details: details, success: false)
    end
  end

  context 'when retrieving the next application' do
    it 'displays a notification banner' do
      click_on 'Your list'
      click_on 'Review next application'

      expect(page).to have_notification_banner(text: 'You must be allocated to a work queue to review applications',
                                               details: details, success: false)
    end
  end

  context 'when assigning an application to your list' do
    it 'displays a notification banner' do
      click_on 'Search'
      click_button 'Search'
      click_on 'Kit Pound'
      click_button 'Assign to your list'

      expect(page).to have_notification_banner(
        text: review_app_banner_text, details: details, success: false
      )
    end
  end

  context 'when reassigning an application' do
    include_context 'with an assigned application'

    let(:current_user_competencies) { [] }

    it 'displays a notification banner' do
      click_on 'Search'
      click_button 'Search'
      click_on 'Kit Pound'
      click_on('Reassign to your list')

      expect(page).to have_notification_banner(
        text: review_app_banner_text, details: details, success: false
      )
    end
  end
end

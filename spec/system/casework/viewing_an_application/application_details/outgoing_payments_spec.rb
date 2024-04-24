require 'rails_helper'

RSpec.describe 'Viewing the outgoing payments of an application' do
  include_context 'with stubbed application'

  before do
    visit crime_application_path(application_id)
  end

  context 'with outgoing payment details' do
    it { expect(page).to have_content('Payments the client pays') }

    # rubocop:disable RSpec/MultipleExpectations
    it 'shows outgoing payments details' do
      expect(page).to have_content('Childcare payments £982.81 every week')
      expect(page).to have_content('Maintenance payments to a former partner Does not pay')
      expect(page).to have_content('Contributions towards criminal or civil legal aid £12.34 every week')
      expect(page).to have_content('Case reference of the criminal rep order or civil certificate CASE1234')
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context 'with no outgoing payments details' do
    let(:application_data) do
      super().deep_merge(
        'means_details' => {
          'outgoings_details' => { 'outgoings' => [], 'has_no_other_outgoings' => 'yes' }
        }
      )
    end

    it 'shows outgoing payment details' do
      expect(page).to have_content('Which payments does the client pay? None')
    end
  end
end

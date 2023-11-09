require 'rails_helper'

RSpec.shared_examples 'an ordered user list' do |options|
  let(:path) { options.fetch(:path) }
  let(:expected_order) { options.fetch(:expected_order) }
  let(:column_num) { options.fetch(:column_num) }

  before do
    users = [
      {
        first_name: 'Hassan',
        last_name: 'Example',
        email: 'hassan.example@example.com',
        auth_subject_id: SecureRandom.uuid
      },
      {
        first_name: 'Hassan',
        last_name: 'Sample',
        email: 'hassan.sample@example.com',
        auth_subject_id: SecureRandom.uuid
      },
      {
        first_name: 'Arthur',
        last_name: 'Sample',
        email: 'arthur.sample@example.com',
        auth_subject_id: SecureRandom.uuid
      }
    ]

    User.insert_all(users) # rubocop:disable Rails/SkipsModelValidations

    visit path
  end

  it 'is ordered' do
    expect(page.all("tbody tr td:nth-child(#{column_num})").map(&:text)).to eq expected_order
  end
end

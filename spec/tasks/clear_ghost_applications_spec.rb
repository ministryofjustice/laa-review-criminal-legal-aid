require 'rails_helper'
require 'rake'

RSpec.describe 'clear_ghost_applications', type: :task do # rubocop:disable RSpec/MultipleMemoizedHelpers
  # rubocop:disable RSpec/IndexedLet
  let(:open_application1) { SecureRandom.uuid }
  let(:open_application2) { SecureRandom.uuid }
  let(:closed_application1) { SecureRandom.uuid }
  let(:closed_application2) { SecureRandom.uuid }
  let(:ghost_application1) { SecureRandom.uuid }
  let(:ghost_application2) { SecureRandom.uuid }
  # rubocop:enable RSpec/IndexedLet

  let!(:user_a) do
    User.create!(
      auth_oid: '35d581ba-b1f5-4d96-8b1d-233bfe67dfe5',
      first_name: 'User',
      last_name: 'A',
      email: 'User.A@justice.gov.uk'
    )
  end

  let!(:user_b) do
    User.create!(
      auth_oid: '992c1667-745f-4eda-848b-eec7cd92d7fa',
      first_name: 'User',
      last_name: 'B',
      email: 'User.B@justice.gov.uk'
    )
  end

  # rubocop:disable Rails/SkipsModelValidations
  before do
    Rake::Task.define_task(:environment)
    Rake.application.rake_require 'tasks/clear_ghost_applications'

    # User A applications
    Review.insert({ application_id: open_application1 })
    CurrentAssignment.insert({ user_id: user_a.id, assignment_id: open_application1 })
    Review.insert({ reviewer_id: user_a.id, application_id: closed_application1 })

    # User B applications
    Review.insert({ application_id: open_application2 })
    CurrentAssignment.insert({ user_id: user_b.id, assignment_id: open_application2 })
    Review.insert({ reviewer_id: user_b.id, application_id: closed_application2 })

    # Ghost assignment  - Closed by User A but assigned to User B
    Review.insert({ reviewer_id: user_a.id, application_id: ghost_application1 })
    CurrentAssignment.insert({ user_id: user_b.id, assignment_id: ghost_application1 })

    # Ghost assignment  - Closed by User B but assigned to User A
    Review.insert({ reviewer_id: user_b.id, application_id: ghost_application2 })
    CurrentAssignment.insert({ user_id: user_a.id, assignment_id: ghost_application2 })
  end
  # rubocop:enable Rails/SkipsModelValidations

  it 'clears ghost current_assignment records' do # rubocop:disable RSpec/MultipleExpectations
    expect { Rake::Task['clear_ghost_applications'].invoke }.to change { CurrentAssignment.count }.from(4).to(2)
    expect(CurrentAssignment.where(user_id: user_b.id, assignment_id: ghost_application1)).to be_empty
    expect(CurrentAssignment.where(user_id: user_a.id, assignment_id: ghost_application2)).to be_empty
  end
end

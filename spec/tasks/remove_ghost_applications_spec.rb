require 'rails_helper'
require 'rake'

RSpec.describe 'remove_ghost_applications', type: :task do
  # rubocop:disable RSpec/IndexedLet
  let(:open_application1) { SecureRandom.uuid }
  let(:open_application2) { SecureRandom.uuid }
  let(:closed_application1) { SecureRandom.uuid }
  let(:closed_application2) { SecureRandom.uuid }
  let(:ghost_application1) { SecureRandom.uuid }
  let(:ghost_application2) { SecureRandom.uuid }
  # rubocop:enable RSpec/IndexedLet

  # let(:user_a_apps) { [open_application_1, closed_application_1, ghost_application_1] }
  # let(:user_b_apps) { [open_application_2, closed_application_2, ghost_application_2] }
  # let(:open_applications) { [open_application_1, open_application_2] }

  # rubocop:disable Rails/SkipsModelValidations
  before do
    Rake::Task.define_task(:environment)
    Rake.application.rake_require 'tasks/remove_ghost_applications'

    user_a = User.create!(
      auth_oid: '35d581ba-b1f5-4d96-8b1d-233bfe67dfe5',
      first_name: 'User',
      last_name: 'A',
      email: 'User.A@justice.gov.uk'
    )
    user_b = User.create!(
      auth_oid: '992c1667-745f-4eda-848b-eec7cd92d7fa',
      first_name: 'User',
      last_name: 'B',
      email: 'User.B@justice.gov.uk'
    )

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

  it 'removes ghost current_assignment records' do
    expect { Rake::Task['remove_ghost_applications'].invoke }.to change { CurrentAssignment.count }.from(4).to(2)
  end
end

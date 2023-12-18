require 'rails_helper'

RSpec.describe 'Caseworker report' do
  include_context 'when viewing a temporal report'
  let(:interval) { Types::TemporalInterval['daily'] }
  let(:period) { '2023-01-01' }

  it 'includes the correct colgroup detail headings' do # rubocop:disable RSpec/ExampleLength
    colgroup_detail_headings = all('.app-table thead tr.colgroup-details th').map(&:text)

    expected = [
      ' ',
      'fromlist',
      'fromanother',
      'total',
      'fromself',
      'byanother',
      'total',
      'sentback',
      'completed',
      'total',
      'assigned un-assigned',
      'assigned closed',
      'closed sent back'
    ]

    expect(colgroup_detail_headings).to eq(expected)
  end

  it_behaves_like 'a table with sortable columns' do
    let(:active) { ['user_name'] }
    let(:active_direction) { 'ascending' }
    let(:inactive) do
      %w[
        percentage_closed_by_user
        percentage_closed_sent_back
        percentage_unassigned_from_user
        total_assigned_to_user
        total_closed_by_user
        total_unassigned_from_user
      ]
    end
  end
end

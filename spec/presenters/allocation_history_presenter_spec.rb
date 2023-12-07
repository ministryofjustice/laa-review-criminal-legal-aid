require 'rails_helper'

RSpec.describe AllocationHistoryPresenter do
  subject(:allocation_history_presenter) { described_class.new(event) }

  let(:caseworker) { User.create(email: 'Zoe.Example@example.com') }
  let(:supervisor) do
    User.create(email: 'Ben.Example@example.com', first_name: 'Ben', last_name: 'Example', role: Types::SUPERVISOR_ROLE)
  end
  let(:event) do
    Allocating::CompetenciesSet.new(data: { user_id: caseworker.id,
                                            by_whom_id: by_whom_id,
                                            competencies: competencies })
  end
  let(:competencies) { [] }
  let(:by_whom_id) { supervisor.id }

  describe '#description' do
    subject(:description) { allocation_history_presenter.description }

    it { is_expected.to eq 'Competencies set to no competencies' }

    context 'with competencies' do
      let(:competencies) { %w[extradition national_crime_team] }

      it { is_expected.to eq 'Competencies set to Extradition, CAT 2' }
    end
  end

  describe '#supervisor_name' do
    subject(:supervisor_name) { allocation_history_presenter.supervisor_name }

    it { is_expected.to eq 'Ben Example' }

    context 'without by whom id' do
      let(:by_whom_id) { nil }

      it { is_expected.to eq '--' }
    end
  end

  describe '#supervisor_id' do
    subject(:supervisor_id) { allocation_history_presenter.supervisor_id }

    it { is_expected.to eq supervisor.id }

    context 'without by whom id' do
      let(:by_whom_id) { nil }

      it { is_expected.to be_nil }
    end
  end
end

RSpec.shared_context 'when adding a decision by MAAT ID' do
  let(:maat_decision) do
    Maat::Decision.new(
      app_created_date: Date.new(2024, 2, 1),
      date_means_created:  Date.new(2024, 2, 2),
      case_id: 'NOL-123',
      case_type: 'SUMMARY ONLY',
      funding_decision: maat_decision_funding_decision,
      ioj_assessor_name: 'Jo Bloggs',
      ioj_reason: maat_decision_ioj_reason,
      ioj_result: 'PASS',
      maat_ref: maat_decision_maat_id,
      means_assessor_name: 'Jo Bloggs',
      means_result: 'PASS',
      usn: maat_decision_reference
    )
  end

  let(:maat_decision_funding_decision) { 'GRANTED' }
  let(:maat_decision_ioj_reason) { 'Justification comment' }
  let(:maat_decision_reference) { 6_000_001 }
  let(:maat_decision_maat_id) { 999_333 }
  let(:mock_get_decision) { instance_double(Maat::GetDecision) }

  before do
    allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
      .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))

    allow(FeatureFlags).to receive(:adding_decisions) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }

    allow(mock_get_decision).to receive(:by_maat_id!).with(maat_decision_maat_id).and_return(maat_decision)
    allow(Maat::GetDecision).to receive(:new).and_return(mock_get_decision)
  end
end

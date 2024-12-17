RSpec.shared_context 'when adding a decision by MAAT ID' do
  let(:maat_decision) do
    Maat::Decision.new(
      maat_ref: maat_decision_maat_id,
      usn: maat_decision_reference,
      ioj_result: 'PASS',
      ioj_assessor_name: 'Jo Bloggs',
      app_created_date: 1.day.ago.to_s,
      means_result: 'PASS',
      means_assessor_name: 'Jo Bloggs',
      date_means_created:  1.day.ago.to_s,
      funding_decision: maat_decision_funding_decision
    )
  end

  let(:maat_decision_funding_decision) { 'GRANTED' }
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

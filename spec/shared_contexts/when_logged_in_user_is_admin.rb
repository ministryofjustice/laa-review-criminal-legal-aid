RSpec.shared_context 'when logged in user is admin', shared_context: :metadata do
  let(:current_user_can_manage_others) { true }

  before do
    allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: false)
    }
  end
end

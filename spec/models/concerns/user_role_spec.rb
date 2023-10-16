require 'rails_helper'

RSpec.describe UserRole do
  let(:user) do
    User.new(
      email: 'example@justice.digital.gov.uk',
      auth_subject_id: SecureRandom.uuid,
      last_auth_at: 10.days.ago,
      first_auth_at: 10.days.ago
    )
  end

  describe '.role' do
    it 'defaults to `caseworker`' do
      expect(user.role).to eq 'caseworker'
    end

    context 'when role is invalid' do
      it 'fails user validation' do
        expect { user.role = 'CaSEWorker' }.to raise_error ArgumentError, "'CaSEWorker' is not a valid role"
      end

      it 'does not persist user' do
        expect { user.update_column(:role, 'CaSEWorker') } # rubocop:disable Rails/SkipsModelValidations
          .to raise_error StandardError
      end
    end
  end

  describe '#can_read_application?' do
    context 'when user is supervisor' do
      it 'returns true' do
        user.role = 'supervisor'
        expect(user.can_read_application?).to be true
      end
    end

    context 'when user is caseworker' do
      it 'returns true' do
        user.role = 'caseworker'
        expect(user.can_read_application?).to be true
      end
    end
  end

  describe '#can_write_application?' do
    context 'when user is supervisor' do
      it 'returns true' do
        user.role = 'supervisor'
        expect(user.can_write_application?).to be true
      end
    end

    context 'when user is caseworker' do
      it 'returns false' do
        user.role = 'caseworker'
        expect(user.can_write_application?).to be false
      end
    end
  end

  describe '#can_access_reporting_dashboard?' do
    subject(:can_access_reporting_dashboard) { user.can_access_reporting_dashboard? }

    context 'when user is supervisor' do
      before { user.role = Types::UserRole['supervisor'] }

      it { is_expected.to be true }
    end

    context 'when user is caseworker' do
      before { user.role = Types::UserRole['caseworker'] }

      it { is_expected.to be false }
    end

    context 'when user is user manager' do
      before { user.can_manage_others = true }

      it { is_expected.to be false }

      context 'when user managers are allowed service access' do
        before do
          allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
            instance_double(FeatureFlags::EnabledFeature, enabled?: true)
          }
        end

        it { is_expected.to be true }
      end
    end
  end

  describe '#service_user?' do
    context 'when user is not a user manager' do
      it 'returns true for caseworker or supervisor' do
        user.can_manage_others = false

        [UserRole::CASEWORKER, UserRole::SUPERVISOR].each do |role|
          user.role = role
          expect(user.service_user?).to be true
        end
      end

      it 'returns false for data_analyst' do
        user.can_manage_others = false
        user.role = UserRole::DATA_ANALYST

        expect(user.service_user?).to be false
      end
    end

    context 'when user is a user manager' do
      it 'returns false for all user roles' do
        user.can_manage_others = true

        Types::UserRole.values.each do |role| # rubocop:disable Style/HashEachMethods
          user.role = role
          expect(user.service_user?).to be false
        end
      end

      context 'when user managers are allowed service access' do
        before do
          allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
            instance_double(FeatureFlags::EnabledFeature, enabled?: true)
          }
        end

        it 'returns true for all user roles' do
          user.can_manage_others = true

          Types::UserRole.values.each do |role| # rubocop:disable Style/HashEachMethods
            user.role = role
            expect(user.service_user?).to be true
          end
        end
      end
    end
  end

  describe '#reporting_user?' do
    context 'when user is not a user manager' do
      it 'returns true for data_analyst or supervisor' do
        user.can_manage_others = false

        [UserRole::DATA_ANALYST, UserRole::SUPERVISOR].each do |role|
          user.role = role
          expect(user.reporting_user?).to be true
        end
      end

      it 'returns false for caseworker' do
        user.can_manage_others = false
        user.role = UserRole::CASEWORKER

        expect(user.reporting_user?).to be false
      end
    end

    context 'when user is a user manager' do
      it 'returns false for all user roles' do
        user.can_manage_others = true

        Types::UserRole.values.each do |role| # rubocop:disable Style/HashEachMethods
          user.role = role
          expect(user.reporting_user?).to be false
        end
      end
    end
  end

  describe '#user_manager?' do
    context 'with can_manager_others attribute set to true' do
      it 'returns true' do
        user.can_manage_others = true
        expect(user.user_manager?).to be true
      end
    end
  end

  describe '#can_change_role?' do
    context 'when user is active' do
      it 'returns true' do
        expect(user.activated?).to be true
        expect(user.can_change_role?).to be true
      end
    end

    context 'when user is not activated' do
      before do
        user.first_auth_at = nil
      end

      it 'returns false' do
        expect(user.activated?).to be false
        expect(user.can_change_role?).to be false
      end
    end

    context 'when feature flag is disabled' do
      before do
        allow(FeatureFlags).to receive(:basic_user_roles) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
      end

      it 'returns false' do
        expect(user.activated?).to be true
        expect(user.can_change_role?).to be false
      end
    end

    context 'when user is dormant' do
      before do
        user.last_auth_at = 100.days.ago
        user.first_auth_at = 100.days.ago
      end

      it 'returns false' do
        expect(user.dormant?).to be true
        expect(user.can_change_role?).to be false
      end
    end

    context 'when user is deactivated' do
      before do
        user.deactivated_at = Time.zone.now
      end

      it 'returns false' do
        expect(user.deactivated?).to be true
        expect(user.can_change_role?).to be false
      end
    end
  end

  describe '#reports' do
    subject(:reports) { user.reports }

    context 'when user is supervisor' do
      before { user.role = Types::SUPERVISOR_ROLE }

      it { is_expected.to eq %w[caseworker_report volumes_report processed_report workload_report] }
    end

    context 'when user is caseworker' do
      before { user.role = Types::CASEWORKER_ROLE }

      it { is_expected.to eq %w[workload_report processed_report] }
    end

    context 'when user is data_analyst' do
      before { user.role = Types::DATA_ANALYST_ROLE }

      it { is_expected.to eq %w[caseworker_report volumes_report processed_report workload_report] }
    end

    context 'when user is user manager' do
      before { user.can_manage_others = true }

      it { is_expected.to be_empty }

      context 'when user managers are allowed service access' do
        before do
          allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
            instance_double(FeatureFlags::EnabledFeature, enabled?: true)
          }
        end

        it { is_expected.to eq %w[caseworker_report volumes_report processed_report workload_report] }
      end
    end
  end
end

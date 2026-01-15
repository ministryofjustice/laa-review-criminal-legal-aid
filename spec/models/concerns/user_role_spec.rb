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

  describe '#can_access_reporting_dashboard?' do
    it 'returns true when user is supervisor or data analyst' do
      [UserRole::SUPERVISOR, UserRole::DATA_ANALYST].each do |role|
        user.role = role
        expect(user.can_access_reporting_dashboard?).to be true
      end
    end

    it 'returns false when user is caseworker or auditor' do
      [UserRole::CASEWORKER, UserRole::AUDITOR].each do |role|
        user.role = role
        expect(user.can_access_reporting_dashboard?).to be false
      end
    end

    context 'when user is a user manager' do
      before { user.can_manage_others = true }

      it 'returns false for all roles when user managers are not allowed service access' do
        [UserRole::CASEWORKER, UserRole::SUPERVISOR, UserRole::DATA_ANALYST, UserRole::AUDITOR].each do |role|
          user.role = role
          expect(user.can_access_reporting_dashboard?).to be false
        end
      end

      context 'when user managers are allowed service access' do
        before do
          allow(FeatureFlags).to receive(:allow_user_managers_service_access) {
            instance_double(FeatureFlags::EnabledFeature, enabled?: true)
          }
        end

        it 'returns true for all roles' do
          [UserRole::CASEWORKER, UserRole::SUPERVISOR, UserRole::DATA_ANALYST, UserRole::AUDITOR].each do |role|
            user.role = role
            expect(user.can_access_reporting_dashboard?).to be true
          end
        end
      end
    end
  end

  describe '#service_user?' do
    context 'when user is not a user manager' do
      before { user.can_manage_others = false }

      it 'returns true for caseworker, supervisor, data analyst, and auditor' do
        [UserRole::CASEWORKER, UserRole::SUPERVISOR, UserRole::DATA_ANALYST, UserRole::AUDITOR].each do |role|
          user.role = role
          expect(user.service_user?).to be true
        end
      end
    end

    context 'when user is a user manager' do
      before { user.can_manage_others = true }

      it 'returns false for all roles when user managers are not allowed service access' do
        [UserRole::CASEWORKER, UserRole::SUPERVISOR, UserRole::DATA_ANALYST, UserRole::AUDITOR].each do |role|
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

        it 'returns true for all roles' do
          [UserRole::CASEWORKER, UserRole::SUPERVISOR, UserRole::DATA_ANALYST, UserRole::AUDITOR].each do |role|
            user.role = role
            expect(user.service_user?).to be true
          end
        end
      end
    end
  end

  describe '#reporting_user?' do
    context 'when user is not a user manager' do
      before { user.can_manage_others = false }

      it 'returns true for data analyst and supervisor' do
        [UserRole::DATA_ANALYST, UserRole::SUPERVISOR].each do |role|
          user.role = role
          expect(user.reporting_user?).to be true
        end
      end

      it 'returns false for caseworker and auditor' do
        [UserRole::CASEWORKER, UserRole::AUDITOR].each do |role|
          user.role = role
          expect(user.reporting_user?).to be false
        end
      end
    end

    context 'when user is a user manager' do
      before { user.can_manage_others = true }

      it 'returns false for all roles' do
        [UserRole::CASEWORKER, UserRole::SUPERVISOR, UserRole::DATA_ANALYST, UserRole::AUDITOR].each do |role|
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
      before { user.first_auth_at = nil }

      it 'returns false' do
        expect(user.activated?).to be false
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
      before { user.deactivated_at = Time.zone.now }

      it 'returns false' do
        expect(user.deactivated?).to be true
        expect(user.can_change_role?).to be false
      end
    end
  end

  describe '#reports' do
    subject(:reports) { user.reports }

    context 'when user is supervisor' do
      let(:expected_user_reports) do
        %w[
          caseworker_report
          processed_report
          workload_report
          return_reasons_report
          current_workload_report
        ]
      end

      before { user.role = Types::SUPERVISOR_ROLE }

      it { is_expected.to eq expected_user_reports }
    end

    context 'when user is caseworker' do
      before { user.role = Types::CASEWORKER_ROLE }

      it { is_expected.to eq %w[current_workload_report processed_report] }
    end

    context 'when user is data_analyst' do
      before { user.role = Types::DATA_ANALYST_ROLE }

      it { is_expected.to eq Types::Report.values }
    end

    context 'when user is auditor' do
      before { user.role = Types::AUDITOR_ROLE }

      it { is_expected.to eq %w[current_workload_report processed_report] }
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

        it { is_expected.to eq Types::Report.values }
      end
    end
  end

  describe '#admin?' do
    context 'with can_manage_others attribute set to true' do
      it 'returns true' do
        user.can_manage_others = true
        expect(user.admin?).to be true
      end
    end
  end
end
